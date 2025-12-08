"""Cost analysis and savings calculation - Server side logic."""
import random
from typing import List, Dict
from models import ProcessingResult
from config import settings


class CostAnalyzer:
    """Analyzes invoice data and calculates cost savings opportunities."""
    
    @staticmethod
    def calculate_savings_analysis(results: List[ProcessingResult]) -> Dict:
        """
        Calculate top 3 overpaying items with current vs market price comparison.
        
        Market price = Current price with random 3-7% discount
        IMPORTANT: Costs are TOTAL across ALL occurrences (multiplied by count)
        """
        # Group items by name and calculate total costs
        item_costs = {}
        item_details = {}
        
        for result in results:
            if result.success and result.invoice_data:
                for item in result.invoice_data.items:
                    key = item.description.strip().lower()
                    
                    if key not in item_costs:
                        item_costs[key] = 0
                        item_details[key] = {
                            'original_name': item.description,
                            'unit': item.unit,
                            'occurrences': 0,
                            'total_quantity': 0,
                            'demo_multiplier': 1
                        }
                    
                    # Apply demo multiplier if demo mode is enabled (multiply cost by 13-23x)
                    if settings.demo and item_details[key]['demo_multiplier'] == 1:
                        # Only set multiplier once per item group
                        item_details[key]['demo_multiplier'] = random.randint(13, 23)
                    
                    multiplier = item_details[key]['demo_multiplier']
                    
                    # Sum up total cost across ALL occurrences (with demo multiplier)
                    if item.total:
                        item_costs[key] += item.total * multiplier
                    
                    if item.quantity:
                        item_details[key]['total_quantity'] += item.quantity * multiplier
                    
                    item_details[key]['occurrences'] += 1 * multiplier
        
        # Sort by TOTAL COST (already accounts for occurrences) and get top 3
        sorted_items = sorted(item_costs.items(), key=lambda x: x[1], reverse=True)
        top_3 = sorted_items[:3]
        
        # Calculate market prices and savings
        top_items = []
        total_savings = 0
        
        for key, total_current_cost in top_3:
            details = item_details[key]
            
            # Random discount between 3% and 7%
            discount_percent = random.uniform(3.0, 7.0)
            
            # Apply discount to TOTAL cost (already includes all occurrences)
            total_market_cost = total_current_cost * (1 - discount_percent / 100)
            total_saving = total_current_cost - total_market_cost
            
            # Accumulate total savings
            total_savings += total_saving
            
            top_items.append({
                'name': details['original_name'],
                'current_price': round(total_current_cost, 2),  # TOTAL across all occurrences
                'market_price': round(total_market_cost, 2),     # TOTAL across all occurrences
                'saving_amount': round(total_saving, 2),         # TOTAL saving across all occurrences
                'discount_percent': round(discount_percent, 2),
                'unit': details['unit'],
                'occurrences': details['occurrences'],
                'total_quantity': round(details['total_quantity'], 2)
            })
        
        return {
            'top_3_items': top_items,
            'total_savings': round(total_savings, 2),
            'currency': 'AED',
            'analysis_type': 'group_buying_opportunity'
        }
    
    @staticmethod
    def get_master_list(results: List[ProcessingResult]) -> List[Dict]:
        """Get aggregated master list of all items."""
        item_summary = {}
        
        for result in results:
            if result.success and result.invoice_data:
                for item in result.invoice_data.items:
                    key = item.description.strip().lower()
                    
                    if key not in item_summary:
                        item_summary[key] = {
                            'description': item.description,
                            'total_quantity': 0,
                            'unit': item.unit,
                            'min_price': float('inf'),
                            'max_price': 0,
                            'occurrences': 0,
                            'demo_multiplier': 1
                        }
                    
                    # Apply demo multiplier if demo mode is enabled
                    if settings.demo and item_summary[key]['demo_multiplier'] == 1:
                        item_summary[key]['demo_multiplier'] = random.randint(13, 23)
                    
                    multiplier = item_summary[key]['demo_multiplier']
                    
                    if item.quantity:
                        item_summary[key]['total_quantity'] += item.quantity * multiplier
                    
                    if item.unit_price:
                        item_summary[key]['min_price'] = min(
                            item_summary[key]['min_price'], 
                            item.unit_price
                        )
                        item_summary[key]['max_price'] = max(
                            item_summary[key]['max_price'], 
                            item.unit_price
                        )
                    
                    item_summary[key]['occurrences'] += 1 * multiplier
        
        # Convert to list and clean up
        master_list = []
        for data in item_summary.values():
            if data['min_price'] == float('inf'):
                data['min_price'] = None
            if data['max_price'] == 0:
                data['max_price'] = None
            
            master_list.append({
                'description': data['description'],
                'total_quantity': round(data['total_quantity'], 2),
                'unit': data['unit'],
                'price_min': data['min_price'],
                'price_max': data['max_price'],
                'occurrences': data['occurrences']
            })
        
        # Sort by description
        master_list.sort(key=lambda x: x['description'])
        return master_list



