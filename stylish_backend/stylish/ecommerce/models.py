from django.db import models

# Create your models here.
from django.db import models
import uuid
from django.conf import settings
from django.db.models import JSONField
from django.utils.text import slugify
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone

class Category(models.Model):
    id = models.UUIDField(primary_key = True, default = uuid.uuid4, editable= False)
    name = models.CharField(max_length=100)
    slug = models.SlugField(max_length = 120, null= True, blank = True)
    description = models.TextField(null = True, blank= True)
    image = models.ImageField(upload_to= 'categories/', null = True, blank = True)
    parent = models.ForeignKey('self', null = True, blank = True, on_delete=models.SET_NULL, related_name='children')
    is_active=models.BooleanField(default = True)
    created_at = models.DateTimeField(auto_now_add = True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name_plural = 'Categories'
        indexes = [
            models.Index(fields = ['name']),
            models.Index(fields = ['slug']),
        ]
        ordering = ['name']
        constraints = [
            models.UniqueConstraint(
                fields= ['name', 'parent'], 
                name = 'unique_name_parent_combination'
            )
        ]
        
    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)
        
    def __str__(self):
        return self.name
    
class Product(models.Model):
    id = models.UUIDField(primary_key = True, default= uuid.uuid4, editable = False)
    name = models.CharField(max_length=200)
    description = models.TextField()
    category = models.ForeignKey(Category, on_delete= models.CASCADE)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    discount_price = models.DecimalField(max_digits=10, decimal_places=2, null = True, blank = True)
    rating = models.DecimalField(max_digits=3, decimal_places=1, default = 0)
    reviews_count = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add =True)
    updated_at = models.DateTimeField(auto_now = True)
    cost = models.DecimalField(max_digits=10, decimal_places=2) 
    
    @property
    def stock(self):
        """Return current stock from the related inventory record"""
        inventory = getattr(self, 'inventory', None)
        if inventory:
            return inventory.current_stock
        if self.variants.exists():
            return sum(self.variants.values_list('stock', flat = True))
        
        return 0
    
    @property
    def initial_stock(self):
        inventory = getattr(self, 'inventory', None)
        return inventory.initial_stock if inventory else 0
    
    @property
    def stock_status(self):
        inventory = getattr(self, 'inventory', None)
        return inventory.stock_status if inventory else 'unknown'
    
    @property
    def primary_image(self):
        """Return the primary image or the first image if no primary is set"""
        primary = self.images.filter(is_primary = True).first()
        if not primary:
            primary = self.images.first()
        return primary
    
    @property
    def primary_image_url(self):
        """Return the URL of the primary image"""
        img = self.primary_image
        return img.image.url if img and img.image else None
    
    @property
    def display_price(self):
        return self.discount_price if self.discount_price is not None else self.price
    
    class Meta:
        indexes = [
            models.Index(fields = ['name', 'category']), 
            models.Index(fields=['price']),
            models.Index(fields=['rating']),            
            models.Index(fields=['is_active']),
        ]
        
        
    def __str__(self):
        return self.name
    
    def ensure_inventory(self, initial_stock = 0):
        """Ensure inventory record exists"""
        from inventory.services import InventoryService
        service = InventoryService()
        return service.initialize_inventory(self, initial_stock)
    
class ProductImage(models.Model):
    id = models.UUIDField(primary_key = True, default= uuid.uuid4, editable = False)
    product = models.ForeignKey(Product, related_name = 'images', on_delete = models.CASCADE)
    image = models.ImageField(upload_to= 'products/', null = True, blank = True, verbose_name='Product Image')
    alt_text = models.CharField(max_length=200)
    order = models.IntegerField(default = 0)
    is_primary = models.BooleanField(default = False)
    created_at = models.DateTimeField(auto_now_add = True)
    
    class Meta:
        ordering = ['order']
        indexes = [
            models.Index(fields = ['product', 'order'])
            
        ]
        
        
class ProductVariation(models.Model):
    """A category of variation like 'Size', 'Color', etc."""
    id = models.UUIDField(primary_key = True, default = uuid.uuid4, editable= False)
    product = models.ForeignKey(Product, related_name = 'variation_types', on_delete=models.CASCADE)
    name = models.CharField(max_length=50) 
    values = JSONField()
    created_at = models.DateTimeField(auto_now_add = True)
    updated_at = models.DateTimeField(auto_now = True)
    
    class Meta:
        unique_together = ('product', 'name')
        
class ProductVariant(models.Model):
    id = models.UUIDField(primary_key = True, default = uuid.uuid4, editable= False)
    product = models.ForeignKey(Product, related_name = 'variants', on_delete=models.CASCADE)
    attributes = JSONField(null=True, blank = True)
    sku = models.CharField(max_length=100, blank =True, null = True)
    price = models.DecimalField(max_digits=10, decimal_places=2, null = True, blank = True)
    discount_price = models.DecimalField(max_digits=10, decimal_places=2, null = True, blank = True)
    stock = models.IntegerField(default = 0)
    image = models.ForeignKey(ProductImage, null = True, blank = True, on_delete=models.SET_NULL, related_name = 'variants')
    created_at = models.DateTimeField(auto_now_add = True)
    updated_at = models.DateTimeField(auto_now = True)
    
    class Meta:
        indexes = [
            models.Index(fields = ['product']),
        ]
        
    def save(self, *args, **kwargs):
        if not self.sku:
            product_code = self.product.name[:3].upper()
            variant_code = '-'.join(f"{key[:1]} {val[:2]}" for key, val in sorted(self.attributes.items()))
            self.sku = f"{product_code}-{variant_code}-{uuid.uuid4().hex[:6].upper()}"
        super().save(*args, **kwargs)
        
    @property
    def effective_price(self):
        return self.discount_price if self.discount_price else self.price or self.product.price
    
class Order(models.Model):
    STATUS_CHOICES = [
        ('completed', 'Completed'), 
        ('processing', 'Processing'), 
        ('rejected', 'Rejected'), 
        ('on_hold', 'On Hold'), 
        ('in_transit', 'In Transit')
    ]
    id = models.UUIDField(primary_key = True, default = uuid.uuid4, editable= False)
    user = models.ForeignKey('authentication.CustomUser', on_delete= models.CASCADE)
    total_amount =models.DecimalField(max_digits=10, decimal_places=2)
    shipping_address = models.TextField()
    contact = models.CharField(max_length = 20)
    status = models.CharField(
        max_length=20, 
        choices=STATUS_CHOICES, 
        default= 'processing'
    )
    tracking_number = models.CharField(max_length=60, null = True, blank = True)
    created_at = models.DateTimeField(auto_now_add = True)
    updated_at = models.DateTimeField(auto_now = True)
    categories = models.ManyToManyField(Category, through = 'OrderCategory', related_name='orders')
    
    class Meta:
        indexes = [
            models.Index(fields=['user', 'status']), 
            models.Index(fields= ['created_at']), 
        ]
        
    def __str__(self):
        return f"Order {self.id} - {self.user.get_full_name()}"
    
    
class OrderCategory(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete = models.CASCADE)
    class Meta:
        unique_together= ('order', 'category')
        
        
class OrderItem(models.Model):
    id = models.UUIDField(primary_key = True, default = uuid.uuid4, editable = False)
    order = models.ForeignKey(Order, related_name = 'items', on_delete = models.CASCADE)
    product = models.ForeignKey(Product, on_delete = models.CASCADE)
    quantity = models.IntegerField()
    size = models.CharField(max_length = 10)
    variation = models.CharField(max_length=20)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add = True)
    
    class Meta:
        indexes = [
            models.Index(fields = ['order', 'product'])
            
        ]
        
class Review(models.Model):
    id = models.UUIDField(primary_key = True, default = uuid.uuid4, editable= False)
    user = models.ForeignKey('authentication.CustomUser',  on_delete = models.CASCADE )
    product = models.ForeignKey(Product, related_name = 'reviews', on_delete = models.CASCADE )
    rating = models.IntegerField()
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add = True)
    updated_at = models.DateTimeField(auto_now = True)
    
    class Meta:
        indexes = [
            models.Index(fields = ['product', 'rating']),
            models.Index(fields = ['user']),
        ]
        unique_together = ['user', 'product']
        
        
class WishList(models.Model):
    id = models.UUIDField(primary_key = True, default = uuid.uuid4, editable = False)
    user = models.ForeignKey('authentication.CustomUser', on_delete = models.CASCADE)
    products = models.ManyToManyField(Product, through='WishListItem')
    created_at = models.DateTimeField(auto_now_add = True)
    updated_at = models.DateTimeField(auto_now = True)
    
    class Meta:
        indexes = [
            models.Index(fields = ['user'])
        ]
        
class WishListItem(models.Model):
    id = models.UUIDField(primary_key = True, default = uuid.uuid4, editable = False)
    wishlist = models.ForeignKey(WishList, on_delete = models.CASCADE)
    product = models.ForeignKey(Product, on_delete = models.CASCADE)
    added_at = models.DateTimeField(auto_now_add = True)
    
    class Meta:
        unique_together = ['wishlist', 'product']
        indexes = [
            models.Index(fields = ['wishlist', 'product']), 
        ]
        
class Banner(models.Model):
    """Promotional banners for homepae carousel"""
    
    title = models.CharField(max_length=100)
    subtitle= models.CharField(max_length = 200, blank = True)
    image = models.ImageField(upload_to='banners/')
    link_url = models.CharField(max_length = 255, blank = True)
    link_text = models.CharField(max_length=50, blank = True)
    is_active = models.BooleanField(default=True)
    start_date = models.DateTimeField(null = True, blank = True)
    end_date = models.DateTimeField(null = True, blank = True)
    display_order = models.IntegerField(default = 0)
    created_at = models.DateTimeField(auto_now_add = True)
    updated_at = models.DateTimeField(auto_now = True)
    
    flash_sale = models.ForeignKey('FlashSale', on_delete = models.SET_NULL, null = True, blank = True, related_name = 'banners')
    
    class Meta:
        ordering = ['display_order', '-created_at']
        indexes = [
            models.Index(fields=['is_active']),
            models.Index(fields=['display_order']),
            models.Index(fields=['flash_sale']),
        ]
        
    def __str__(self):
        return self.title
    
    @property
    def is_currently_active(self):
        """Check if banner is active and within date range"""
        if not self.is_active:
            return False
        now = timezone.now()
        
        if self.start_date  and self.start_date > now:
            return False
        
        if self.end_date and self.end_date <=now:
            return False
        
        return True
    
    @property 
    def status_display(self):
        if not self.is_active:
            return 'Inactive'
        now = timezone.now()
        
        if self.start_date  and self.start_date > now:
            return 'Scheduled'
        
        if self.end_date and self.end_date <=now:
            return 'Expired'
        
        return 'Active' 
    
class FlashSale(models.Model):
    """Flash sale model for time-limited promotions"""
    id = models.UUIDField(primary_key = True, default = uuid.uuid4, editable = False)
    title = models.CharField(max_length=255)
    description = models.TextField()
    image = models.ImageField(upload_to='flash_sales/', null = True, blank = True)
    discount_percentage = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(99)])
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    is_active = models.BooleanField(default = True)
    created_at = models.DateTimeField(auto_now_add = True)
    updated_at = models.DateTimeField(auto_now = True)
    total_revenue = models.DecimalField(max_digits=12, decimal_places=2, default = 0)
    revenue_increase = models.DecimalField(max_digits=6, decimal_places=2, default = 0)
    order_increase = models.DecimalField(max_digits=6, decimal_places=2, default = 0)
    total_orders = models.IntegerField(default  = 0)
    units_sold = models.IntegerField(default  = 0)
    units_sold_increase = models.DecimalField(max_digits=6, decimal_places=2, default = 0)
    conversion_rate = models.DecimalField(max_digits=6, decimal_places=2, default = 0)
    conversion_rate_increase = models.DecimalField(max_digits=6, decimal_places=2, default = 0)
    purchase_limit = models.IntegerField(null = True, blank = True)
    minimun_order_value = models.DecimalField(max_digits=6, decimal_places=2, default = 0, null = True, blank = True)
    allow_stacking_discounts = models.BooleanField(default = False)
    is_public = models.BooleanField(default=True)
    class Meta:
        ordering = ['-created_at']
        
    @property
    def is_ongoing(self):
        now = timezone.now()
        return self.is_active and self.start_date <= now and self.end_date > now
    
    @property
    def time_remaining(self):
        if not self.is_ongoing:
            return None
        return self.end_date - timezone.now()
    
    @property
    def status(self):
        now = timezone.now()
        if not self.is_active:
            return 'inactive'
        if self.start_date > now:
            return 'upcoming'
        if self.end_date <= now:
            return 'expired'
        return 'active'
    
    @property
    def average_order_value(self):
        if self.total_orders > 0:
            return self.total_revenue / self.total_orders
        return 0
    
    def __str__(self):
        return f"{self.title} ({self.status})"
    
    
class FlashSaleItem(models.Model):
    """Individual items included in a flash sale"""
    id = models.UUIDField(primary_key = True, default = uuid.uuid4, editable = False)
    flash_sale = models.ForeignKey(FlashSale, related_name='items', on_delete = models.CASCADE) 
    product = models.ForeignKey(Product, on_delete = models.CASCADE) 
    override_discount = models.IntegerField(null = True, blank = True)
    stock_limit = models.IntegerField(null = True, blank = True)
    units_sold = models.IntegerField(default = 0)
    item_purchase_limit = models.IntegerField(null = True, blank = True)
    revenue = models.DecimalField(max_digits = 12, decimal_places = 2, default = 0)
    
    class Meta:
        unique_together = ['flash_sale', 'product']
        
    @property
    def effective_discount(self):
        if self.override_discount is not None:
            return self.override_discount
        return self.flash_sale.discount_percentage
    
    @property
    def remaining_stock(self):
        if self.stock_limit is None:
            return None
        return self.stock_limit - self.units_sold
    
    @property
    def is_stock_limited(self):
        return self.stock_limit is not None
    
    @property
    def is_purchase_limited(self):
        return self.item_purchase_limit is not None or self.flash_sale.purchase_limit is not None
    
    @property
    def effective_purchase_limit(self):
        if self.item_purchase_limit is not None:
            return self.item_purchase_limit
        return self.flash_sale.purchase_limit
    
    def __str__(self):
        return f"{self.product.name} in {self.flash_sale.title}"
        
        