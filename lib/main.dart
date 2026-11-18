import 'package:flutter/material.dart';

void main() => runApp(const GulApp());

class Product {
  final String name;
  final int price;
  final String emoji;
  final String category;
  const Product(this.name, this.price, this.emoji, this.category);
}

const categories = ['Розалар', 'Лолалар', 'Букеттер', 'Белектер'];

const products = [
  Product('Кызыл роза букети', 1500, '🌹', 'Розалар'),
  Product('Ак роза букети', 1600, '🌹', 'Розалар'),
  Product('Лола гүлдөрү', 1200, '🌷', 'Лолалар'),
  Product('Күнкарама гүлү', 900, '🌻', 'Букеттер'),
  Product('Аралаш букет', 1800, '💐', 'Букеттер'),
  Product('Белек куту', 2000, '🎁', 'Белектер'),
];

class GulApp extends StatelessWidget {
  const GulApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Гүл Себет',
    theme: ThemeData(colorSchemeSeed: Colors.pink, useMaterial3: true),
    home: const AppShell(),
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final List<Product> cart = [];
  final Set<Product> favorites = {};

  static const titles = [
    'Гүл Себет 🌸',
    'Меню',
    'Жартыргандарым',
    'Себетим',
    'Профиль',
  ];

  void addToCart(Product p) {
    setState(() => cart.add(p));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${p.name} себетке кошулду'),
        duration: const Duration(seconds: 1),
      ));
  }

  void toggleFavorite(Product p) {
    setState(() {
      if (!favorites.remove(p)) favorites.add(p);
    });
  }

  void removeFromCart(int i) => setState(() => cart.removeAt(i));

  void clearCart() => setState(() => cart.clear());

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      Column(
        children: [
          const HomeBanner(),
          Expanded(
            child: ProductGrid(
              items: products,
              favorites: favorites,
              onAdd: addToCart,
              onFavorite: toggleFavorite,
            ),
          ),
        ],
      ),
      CategoriesPage(
        favorites: favorites,
        onAdd: addToCart,
        onFavorite: toggleFavorite,
      ),
      favorites.isEmpty
          ? const Center(child: Text('Тандалмалар бош'))
          : ProductGrid(
        items: favorites.toList(),
        favorites: favorites,
        onAdd: addToCart,
        onFavorite: toggleFavorite,
      ),
      CartPage(cart: cart, onRemove: removeFromCart, onClear: clearCart),
      const AccountPage(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[index])),
      body: pages[index],
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
          labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11)),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Башкы бет',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Меню',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: favorites.isNotEmpty,
                label: Text('${favorites.length}'),
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: Badge(
                isLabelVisible: favorites.isNotEmpty,
                label: Text('${favorites.length}'),
                child: const Icon(Icons.favorite),
              ),
              label: 'Жактыргандарым',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cart.isNotEmpty,
                label: Text('${cart.length}'),
                child: const Icon(Icons.shopping_basket_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cart.isNotEmpty,
                label: Text('${cart.length}'),
                child: const Icon(Icons.shopping_basket),
              ),
              label: 'Себетим',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final List<Product> items;
  final Set<Product> favorites;
  final void Function(Product) onAdd;
  final void Function(Product) onFavorite;

  const ProductGrid({
    super.key,
    required this.items,
    required this.favorites,
    required this.onAdd,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final p = items[i];
        final fav = favorites.contains(p);
        return Card(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () => onFavorite(p),
                  icon: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    color: fav ? Colors.pink : null,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(p.emoji, style: const TextStyle(fontSize: 48)),
                    Text(p.name, textAlign: TextAlign.center),
                    Text('${p.price} сом',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => onAdd(p),
                      child: const Text('Себетке кошуу'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoriesPage extends StatefulWidget {
  final Set<Product> favorites;
  final void Function(Product) onAdd;
  final void Function(Product) onFavorite;

  const CategoriesPage({
    super.key,
    required this.favorites,
    required this.onAdd,
    required this.onFavorite,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String selected = categories.first;

  @override
  Widget build(BuildContext context) {
    final items = products.where((p) => p.category == selected).toList();
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              for (final c in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: c == selected,
                    onSelected: (_) => setState(() => selected = c),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ProductGrid(
            items: items,
            favorites: widget.favorites,
            onAdd: widget.onAdd,
            onFavorite: widget.onFavorite,
          ),
        ),
      ],
    );
  }
}

class CartPage extends StatelessWidget {
  final List<Product> cart;
  final void Function(int) onRemove;
  final VoidCallback onClear;

  const CartPage({
    super.key,
    required this.cart,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) return const Center(child: Text('Себет бош'));
    final total = cart.fold<int>(0, (s, p) => s + p.price);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cart.length,
            itemBuilder: (_, i) {
              final p = cart[i];
              return ListTile(
                leading: Text(p.emoji, style: const TextStyle(fontSize: 28)),
                title: Text(p.name),
                subtitle: Text('${p.price} сом'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onRemove(i),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Жалпы: $total сом', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(onPressed: onClear, child: const Text('Тазалоо')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('Заказ берүү'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 24),
        Center(
          child: CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        ),
        SizedBox(height: 12),
        Center(
          child: Text('Конок',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 24),
        ListTile(leading: Icon(Icons.receipt_long), title: Text('Заказдарым')),
        ListTile(
            leading: Icon(Icons.location_on_outlined), title: Text('Дарек')),
        ListTile(leading: Icon(Icons.language), title: Text('Тил')),
        ListTile(leading: Icon(Icons.login), title: Text('Кирүү')),
      ],
    );
  }
}
class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8FB1), Color(0xFFE91E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сүйгөн адамыңызга гүл жөнөтүңүз',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Бишкек боюнча тез жеткирүү',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Text('💐', style: TextStyle(fontSize: 56)),
        ],
      ),
    );
  }
}