
from django.db import transaction
from .models import InventoryRecord, StockAdjustment

class InventoryService:
    """Service for managing inventory operations"""
    def initialize_inventory(self, product, initial_stock = 0, update_if_exists = False):
        """Initialize inventory record for a product with atomic transaction support"""
        from .models import InventoryRecord, StockAdjustment
        from django.conf import settings
        from django.db import transaction
        
        # set default values
        default_low_stock_threshold = getattr(settings, 'LOW_STOCK_THRESHOLD', 5)
        default_reorder_point = getattr(settings, 'DEFAULT_REORDER_POINT', 3)
        default_reorder_quantity = getattr(settings, 'DEFAULT_REORDER_QUANTITY', 10)
        
        with transaction.atomic():
            inventory, created = InventoryRecord.objects.get_or_create(product = product, defaults= {
                'initial_stock': initial_stock, 
                'current_stock': initial_stock, 
                'low_stock_threshold': default_low_stock_threshold, 
                'reorder_point': default_reorder_point, 
                'reorder_quantity': default_reorder_quantity
            })
            
            if not created and update_if_exists and inventory.initial_stock != initial_stock:
                previous_stock = inventory.current_stock
                adjustment = initial_stock-previous_stock
                
                if adjustment != 0:
                    StockAdjustment.objects.create(
                        inventory= inventory, 
                        quantity= adjustment, 
                        previous_stock = previous_stock, 
                        new_stock = initial_stock, 
                        adjustment_type = 'inventory', 
                        reason ='Initial stock update', 
                        reference = f"Product update: {product.id}"
                    )
                inventory.initial_stock = initial_stock
                inventory.save(update_fields = ['initial_stock'])
                
        return inventory, created
    
    def update_inventory_from_variants(self, product, total_stock, is_sync = False, adjustment_type = None, notes = None):
        """Update inventory record based on variant stocks"""
        inventory = getattr(product, 'inventory', None)
        # if no inventory exists, create one
        if not inventory:
            return self.initialize_inventory(product, total_stock)
        
        # skip if no change in stock
        if inventory.current_stock == total_stock:
            return inventory
        
        # Determine the adjustment type if not provided
        if adjustment_type is None:
            adjustment_type = 'sync' if is_sync else 'inventory'
            
        # Create appropriate message based on adjustment type
        if notes is None:
            if adjustment_type == 'redistribution':
                notes = 'Stock redistribution across variants'
            elif adjustment_type == 'sync':
                notes = 'Synchronized stock with variants'
            else:
                notes = 'Stock updated from variants'
                
        # Create an inventory log entry
        from .models import InventoryLog, StockAdjustment
        
        # Log the inventory change
        InventoryLog.objects.create(
            product = product, 
            previous_stock = inventory.current_stock,
            current_stock= total_stock, 
            adjustment_type = adjustment_type, 
            notes = notes
        )
        
        # Create a stock adjustment record
        StockAdjustment.objects.create(
            inventory = inventory, 
            quantity = total_stock - inventory.current_stock, 
            adjustment_type = adjustment_type, 
            reason = notes, 
            previous_stock = inventory.current_stock, 
            new_stock = total_stock, 
            reference = f'{adjustment_type.capitalize()}: {product.id}'
            
            
        )
        
        # Update the inventory record
        inventory.current_stock = total_stock
        inventory.save(update_fields = ['current_stock'])
        
        return inventory
    
    def adjust_stock(self, inventory_id, data, user):
        """Adjust inventory stock with a specific adjustment type('add', 'remove', 'set')"""
        
        quantity_str = data.get('quantity')
        adjustment_type = data.get('adjustment_type')
        reason = data.get('reason', '')
        reference = data.get('reference', '')
        
        if not quantity_str or not adjustment_type:
            return {'success': False, 'error': 'quantity and adjustment_type are required'}
        
        if adjustment_type not in ['add', 'remove', 'set']:
            return {'success': False, 'error': 'adjustment_type must be "add", "remove", or "set"'}
        
        try:
            quantity = int(quantity_str)
            if quantity<= 0:
                return {'success': False, 'error': 'Quantity must be a positive integer'}
        except (ValueError, TypeError):
            return {'success': False, 'error': 'Invalid quantity format'}
        
        
        try:
            with transaction.atomic():
                # Lock the inventory record to prevent race conditions
                inventory = InventoryRecord.objects.select_for_update().get(id = inventory_id)
                
                previous_stock = inventory.current_stock
                adjustment_amount = 0
                new_stock = 0
                
                if adjustment_type == 'add':
                    adjustment_amount = quantity
                    new_stock = previous_stock + quantity
                    
                elif adjustment_type == 'remove':
                    adjustment_amount= -quantity
                    new_stock = previous_stock-quantity
                    
                elif adjustment_type == 'set':
                    adjustment_amount= quantity - previous_stock
                    new_stock = quantity
                    
                    
                if new_stock < 0:
                    return {
                        'success': False, 
                        'error': 'Adjustment would result in negative stock'
                    }
                    
                if adjustment_amount != 0:
                    adjustment = StockAdjustment.objects.create(
                        inventory= inventory, 
                        quantity = adjustment_amount, 
                        previous_stock = previous_stock, 
                        new_stock = new_stock, 
                        adjustment_type = adjustment_type, 
                        reason= reason, 
                        reference = reference, 
                        admin = user
                    )
                    
                    # Explicitly update the inventory record's stock
                    inventory.current_stock = new_stock
                    inventory.save(update_fields=['current_stock', 'last_updated'])
                    
                    return {
                        'success': True, 
                        'message': 'Stock adjusted successfully', 
                        'old_stock': previous_stock, 
                        'adjustment': adjustment_amount, 
                        'new_stock': new_stock, 
                        'adjustment_id': adjustment.id
                    }
                    
                else: 
                    return {
                        'success': True, 
                        'message': 'No change in stock level.', 
                        'old_stock': previous_stock, 
                        'new_stock': new_stock,
                    }
        except InventoryRecord.DoesNotExist:
            return {'succces': False, 'error': 'Inventory record not found'}
        except Exception as e:
            return {'success': False, 'error': f"An unexpected error occurred: {str(e)}"}
        
    
    def update_inventory_from_variants(self, product, total_stock, is_sync = False, adjustment_type = None, notes = None):
        """Update inventory record based on variant stocks"""
        
        inventory =getattr(product, 'inventory', None)
        
        if not inventory:
            return self.initialize_inventory(product, total_stock)
        
        if inventory.current_stock == total_stock:
            return inventory
        
        if adjustment_type is None:
            adjustment_type= 'sync' if is_sync else 'inventory'
            
        
        if notes is None:
            if adjustment_type == 'redistribution':
                notes = 'Stock redistributed across variants'
                
            elif adjustment_type == 'sync':
                notes = 'Synchronized stock with variants'
            else:
                notes = 'Stock updated from variants'
                
                
        from .models import InventoryLog
        InventoryLog.objects.create(
            product = product, 
            previous_stock = inventory.current_stock, 
            current_stock = total_stock, 
            adjustment_type = adjustment_type,
            notes = notes
        )
        
        
        StockAdjustment.objects.create(
            inventory = inventory, 
            quantity = total_stock - inventory.current_stock, 
            adjustment_type = adjustment_type, 
            reason = notes, 
            previous_stock = inventory.current_stock, 
            new_stock = total_stock,
            reference = f'{adjustment_type.capitalize()}:{product.id}'
        )
        
        inventory.current_stock = total_stock
        inventory.save(updata_fields = ['current_stock'])
        
        return inventory