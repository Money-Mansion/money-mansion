enum ItemCategory {
  furniture,
  realEstate,
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int cost; // Cost in coins
  final int? moneyCost; // Cost in money (if applicable)
  final ItemCategory category;
  final String icon;
  
  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    this.moneyCost,
    required this.category,
    required this.icon,
  });
}
