
# Create your models here.
from django.db import models
import uuid
from django.conf import settings
from django.db.models import F, Sum, Count
from ecommerce.models import Product, Order
from django.utils import timezone
from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver 
from django.db import transaction

class InventoryRecord(models.Model):
    id = models.UUIDField(primary_key=True, default = uuid.uuid4, editable = False) 
    product = models.OneToOneField(Product, on_delete= models.CASCADE, related_name = 'inventory')
    initial_stock= models.IntegerField(default = 0, help_text="Starting stock level - never changes after creation")
    current_stock = models.IntegerField(default = 0, help_text="Current available stock - changes with adjustments")
    low_stock_threshold = models.IntegerField(null= True, blank = True, default = 5)
    reorder_point = models.IntegerField(null = True, blank = True, default=3)
    reorder_quantity = models.IntegerField(null = True, blank = True, default = 10)
    last_updated = models.DateTimeField(auto_now = True)
    
    class Meta:
        indexes = [
            models.Index(fields = ['current_stock']), 
            models.Index(fields=['product']),
            
        ]
        
    def save(self, *args, **kwargs):
        """Override save to clear cache when inventory chagges"""
        is_new = self._state.adding
        super().save(*args, **kwargs)
        
    @property
    def stock_status(self):
        """"Return the stock status based on thresholds"""
        if self.current_stock <= 0:
            return 'out_of_stock'
        threshold = self.low_stock_threshold or getattr(settings, 'LOW_STOCK_THRESHOLD', 5)
        if self.current_stock <= threshold:
            return 'low_stock'
        return 'in_stock'
    
    @property
    def sold_percentage(self):
        """Return percentage of initial stock sold"""
        if self.initial_stock > 0:
            sold = self.initial_stock - self.current_stock
            return round((max(0, sold)/ self.initial_stock)*100, 2)
        return 0.0
    
    def adjust_stock(self, quantity, adjustment_type='manual', reason= '', reference = '', admin = None):
        if self.current_stock + quantity < 0:
            return False, "Adjustment would result in negative stock", None
        adjustment = StockAdjustment.objects.create(
            inventory = self, 
            quantity = quantity, 
            previous_stock = self.current_stock, 
            new_stock = self.current_stock + quantity, 
            adjustment_type = adjustment_type, 
            reason = reason, 
            reference = reference, 
            admin = admin
        )
        
        return True, "Stock adjusted successfully", adjustment
    def __str__(self):
        return f"Inventory for {self.product.name} (Current: {self.current_stock})"
    
    
class StockAdjustment(models.Model):
    """Record all stock movements and adjustments"""
    ADJUSTMENT_TYPES = (
        ('add', 'Add Stock'), 
        ('remove', 'Remove Stock'), 
        ('set', 'Set Stock'), 
        ('manual', 'Manual Adjustment'), 
        ('restock', 'Restock'), 
        ('inventory', 'Inventory Correction'), 
        ('damaged', 'Damages/Lost'), 
        ('sale', 'Sale'), 
        ('return', 'Return'), 
        
    )
    id = models.UUIDField(primary_key=True, default = uuid.uuid4, editable = False) 
    inventory = models.ForeignKey(InventoryRecord, on_delete = models.CASCADE, related_name='adjustments')
    quantity = models.IntegerField(help_text= "Amount of change(psotive for increase, negative for decrease)")
    previous_stock = models.IntegerField(help_text= "Stock level before adjustment")
    adjustment_type = models.CharField(max_length=20, choices=ADJUSTMENT_TYPES, default = 'manual')
    reference = models.CharField(max_length= 100, blank = True, help_text="Order number, invoice number, etc")
    reason = models.TextField(blank = True)
    admin = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete= models.SET_NULL, null = True)
    created_at = models.DateTimeField(auto_now_add = True)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['adjustment_type']),
            models.Index(fields=['created_at']),
            models.Index(fields=['inventory']),
        ]
        
    def save(self, *args, **kwargs):
        if not self.pk:
            with transaction.atomic():
                inventory = InventoryRecord.objects.select_for_update().get(pk = self.inventory.pk)
                
                if inventory.current_stock + self.quantity < 0:
                    raise ValueError("Adjustment would result in negative stock")
                self.previous_stock = inventory.current_stock
                self.new_stock = inventory.current_stock+self.quantity
                
                super().save(*args, **kwargs)
                
                inventory.current_stock = self.new_stock
                inventory.save(update_fields = ['current_stock', 'last_updated'])
                
        else:
            super().save(*args, **kwargs)
                
    def __str__(self):
        return f"{self.get_adjustment_type_display()} (self.quanity:+3) for {self.inventory.product.name}"
         
class InventoryLog(models.Model):
    """Log for inventory-wide operations"""
    product = models.ForeignKey('ecommerce.Product', on_delete = models.CASCADE, related_name= 'inventory_log')
    previous_stock = models.DecimalField(max_digits= 10, decimal_places=2, default = 0)
    current_stock = models.DecimalField(max_digits= 10, decimal_places=2, default = 0)
    adjustment_type = models.CharField(max_length=20, choices = [
        ('addition', 'Addition'), 
        ('reduction', 'Reduction'), 
        ('redistribution', 'Redistribution'),
        ('sync', 'Sync'),
    ])
    notes = models.TextField(blank = True, null  = True)
    created_at = models.DateTimeField(auto_now_add= True)
    class Meta:
        ordering = ['-created_at']
        
        
class VariantStockLog(models.Model):
    """Model to track all stock changes for product variants"""
    product = models.ForeignKey('ecommerce.Product', on_delete=models.CASCADE, related_name='variant_stock_logs')
    variant = models.ForeignKey('ecommerce.ProductVariant', on_delete=models.CASCADE, related_name = 'stock_logs')
    previous_stock = models.DecimalField(max_digits=10, decimal_places=2, default = 0)
    current_stock = models.DecimalField(max_digits=10, decimal_places=2, default = 0)
    
    ADJUSTMENT_TYPES = (
         ('addition', 'Addition'), 
        ('reduction', 'Reduction'), 
        ('redistribution', 'Redistribution'),
        ('deletion', 'Deletion'),
        ('no_change', 'No Change'), 
        ('initial_stock', 'Initial Stock'), 
        ('sync', 'Sync'),
    )
    
    adjustment_type = models.CharField(max_length= 20, choices = ADJUSTMENT_TYPES, default = 'no_change')
    timestamp = models.DateTimeField(default = timezone.now)
    performed_by = models.ForeignKey('authentication.CustomUser', on_delete=models.SET_NULL, null = True, blank = True, related_name = 'variant_stock_adjustments')
    notes = models.TextField(blank = True, null = True)
    
    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields= ['product']),
            models.Index(fields= ['variant']),
            models.Index(fields= ['adjustment_type']),
            models.Index(fields= ['timestamp']),
        ]
        
    @property
    def change_amount(self):
        return self.current_stock - self.previous_stock
    @property
    def is_increase(self):
        return self.current_stock > self.previous_stock
    @property
    def is_decrease(self):
        return self.current_stock < self.previous_stock 
    
    def __str__(self):
        return f"{self.variant}-{self.adjustment_type}- {self.timestamp.strftiem('%Y-%m-%d %H:%M')}"