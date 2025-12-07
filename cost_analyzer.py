"""Cost analysis and savings calculation - Server side logic."""
import random
from typing import List, Dict
from models import ProcessingResult


class CostAnalyzer:
    """Analyzes invoice data and calculates cost savings opportunities."""
    
    @staticmethod
    def calculate_savings_analysis(results: List[ProcessingResult]) -> Dict:
        """
        Calculate top 3 overpaying items with current vs market price comparison.
        
        Market price = Current price with random 3-7% discount
        All logic is server-side.
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
                            'occurrences': 0
                        }
                    
                    if item.total:
                        item_costs[key] += item.total
                    
                    item_details[key]['occurrences'] += 1
        
        # Sort by cost and get top 3
        sorted_items = sorted(item_costs.items(), key=lambda x: x[1], reverse=True)
        top_3 = sorted_items[:3]
        
        # Calculate market prices and savings
        top_items = []
        total_savings = 0
        
        for key, current_price in top_3:
            # Random discount between 3% and 7%
            discount_percent = random.uniform(3.0, 7.0)
            market_price = current_price * (1 - discount_percent / 100)
            saving_amount = current_price - market_price
            total_savings += saving_amount
            
            details = item_details[key]
            top_items.append({
                'name': details['original_name'],
                'current_price': round(current_price, 2),
                'market_price': round(market_price, 2),
                'saving_amount': round(saving_amount, 2),
                'discount_percent': round(discount_percent, 2),
                'unit': details['unit'],
                'occurrences': details['occurrences']
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
                            'occurrences': 0
                        }
                    
                    if item.quantity:
                        item_summary[key]['total_quantity'] += item.quantity
                    
                    if item.unit_price:
                        item_summary[key]['min_price'] = min(
                            item_summary[key]['min_price'], 
                            item.unit_price
                        )
                        item_summary[key]['max_price'] = max(
                            item_summary[key]['max_price'], 
                            item.unit_price
                        )
                    
                    item_summary[key]['occurrences'] += 1
        
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



