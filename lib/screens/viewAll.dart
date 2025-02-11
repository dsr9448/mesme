import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter/material.dart';
import 'package:mesme/screens/ViewItem.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:mesme/widgets/calculateLocation.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class FoodItemsApp extends StatefulWidget {
  final List<Map<String, String>> allFoodItems;
  final rname;
  final rlocation;
  final isOnline;
  final userCoordinate;
  final restrauntCoordinate;
  final quantity;
  final unit;
  final bool food;

  FoodItemsApp(
      {required this.allFoodItems,
      this.rname,
      this.rlocation,
      this.isOnline,
      this.userCoordinate,
      this.restrauntCoordinate,
      this.quantity,
      this.unit,
      required this.food});

  @override
  _FoodItemsAppState createState() => _FoodItemsAppState();
}

class _FoodItemsAppState extends State<FoodItemsApp> {
  TextEditingController search = TextEditingController();
  String searchQuery = '';
  String selectedFilter = 'All';
  ScrollController _scrollController = ScrollController();
  bool _showAppBarSearch = false;

  List<String> category = ['Recommeded', 'Popular', 'New', 'Old'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 180) {
      // Adjust this value based on when you want the search to appear
      if (!_showAppBarSearch) {
        setState(() {
          _showAppBarSearch = true;
        });
      }
    } else {
      if (_showAppBarSearch) {
        setState(() {
          _showAppBarSearch = false;
        });
      }
    }
  }

  Widget customSwitch(Color color, bool status, ValueChanged<bool> onToggle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: FlutterSwitch(
        width: 104.0,
        height: 38.0,
        valueFontSize: 14.0,
        toggleSize: 25.0,
        value: status,
        borderRadius: 30.0,
        padding: 4.0,
        activeText: color == Colors.green
            ? 'Veg'
            : color == Colors.red[800]
                ? 'Non-Veg'
                : color == Colors.orange
                    ? '4.0★'
                    : 'All',
        inactiveText: color == Colors.green
            ? 'Veg'
            : color == Colors.red[800]
                ? 'Non-Veg'
                : color == Colors.orange
                    ? '4.0★'
                    : 'All',
        activeTextColor: Colors.white,
        inactiveTextColor: Colors.grey.shade700,
        showOnOff: true,
        activeIcon: color == Colors.green
            ? const Icon(Icons.eco_outlined, color: Colors.white, size: 16)
            : color == Colors.red[800]
                ? const Icon(Icons.restaurant_menu,
                    color: Colors.white, size: 16)
                : color == Colors.orange
                    ? const Icon(Icons.star, color: Colors.white, size: 16)
                    : const Icon(Icons.fastfood, color: Colors.white, size: 16),
        inactiveIcon: color == Colors.green
            ? Icon(Icons.eco_outlined, color: Colors.grey.shade400, size: 16)
            : color == Colors.red[800]
                ? Icon(Icons.restaurant_menu,
                    color: Colors.grey.shade400, size: 16)
                : color == Colors.orange
                    ? Icon(Icons.star, color: Colors.grey.shade400, size: 16)
                    : Icon(Icons.fastfood,
                        color: Colors.grey.shade400, size: 16),
        activeColor: color,
        inactiveColor: Colors.white,
        inactiveSwitchBorder: Border.all(color: Colors.grey.shade300, width: 1),
        onToggle: onToggle,
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              controller: search,
              cursorColor: Colors.orange.shade700,
              decoration: InputDecoration(
                filled: true,
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                hintText: 'Search in ${widget.rname}',
                fillColor: Colors.transparent,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                searchQuery = search.text;
              });
            },
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.orange),
            ),
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> result =
        isWithin6Km(widget.userCoordinate, widget.restrauntCoordinate);

    bool canAdd = result['distance'] <= 6 ? true : false;
    double distance = result['distance'] ?? 0.0;

    List<Map<String, String>> filteredFoodItems = widget.allFoodItems
        .where((item) =>
            item['name']!.toLowerCase().contains(searchQuery.toLowerCase()) &&
            (selectedFilter == 'rating'
                ? double.parse(item['rating'] ?? '0') >= 4.4
                : selectedFilter == 'All' ||
                    item['vegOrNonVeg'] == selectedFilter))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.orange)),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: _showAppBarSearch ? buildSearchBar() : null,
        bottom: _showAppBarSearch
            ? PreferredSize(
                preferredSize: Size.fromHeight(58),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.shade300, width: 1)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10, top: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customSwitch(
                              Colors.orange.shade700, selectedFilter == 'All',
                              (val) {
                            setState(() => selectedFilter = 'All');
                          }),
                          customSwitch(Colors.green, selectedFilter == 'Veg',
                              (val) {
                            setState(() => selectedFilter = 'Veg');
                          }),
                          customSwitch(
                              Colors.red[800]!, selectedFilter == 'Non-Veg',
                              (val) {
                            setState(() => selectedFilter = 'Non-Veg');
                          }),
                          customSwitch(
                              Colors.orange, selectedFilter == 'rating', (val) {
                            setState(() => selectedFilter = 'rating');
                          }),
                        ],
                      ),
                    ),
                  ),
                ))
            : null,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                  top: 8, left: 10, right: 10, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.rname,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade900,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    '4.5',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '30-35 mins',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          width: 14,
                          child:
                              Icon(Icons.circle, color: Colors.black, size: 6),
                        ),
                        Text(
                          '${distance.toStringAsFixed(2)} Km ',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          width: 14,
                          child:
                              Icon(Icons.circle, color: Colors.black, size: 6),
                        ),
                        Text(
                          'Rajalakshmi Nagar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Bugger, Paneer',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      textAlign: TextAlign.start,
                    )
                  ],
                ),
              ),
            ),
            if (!_showAppBarSearch) buildSearchBar(),
            if (!_showAppBarSearch)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    customSwitch(
                        Colors.orange.shade700, selectedFilter == 'All', (val) {
                      setState(() {
                        selectedFilter = 'All';
                      });
                    }),
                    customSwitch(Colors.green, selectedFilter == 'Veg', (val) {
                      setState(() {
                        selectedFilter = 'Veg';
                      });
                    }),
                    customSwitch(Colors.red[800]!, selectedFilter == 'Non-Veg',
                        (val) {
                      setState(() {
                        selectedFilter = 'Non-Veg';
                      });
                    }),
                    customSwitch(Colors.orange, selectedFilter == 'rating',
                        (val) {
                      setState(() {
                        selectedFilter = 'rating';
                      });
                    }),
                  ],
                ),
              ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                collapsedBackgroundColor: Colors.white,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tilePadding: EdgeInsets.symmetric(horizontal: 10),
                expansionAnimationStyle: AnimationStyle(
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 500),
                ),
                title: Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: Colors.orange.shade700),
                    SizedBox(width: 8),
                    Text(
                      'Recommended (${filteredFoodItems.length})',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700),
                    ),
                  ],
                ),
                trailing: Icon(Icons.keyboard_arrow_down,
                    color: Colors.orange.shade700),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredFoodItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredFoodItems[index];
                      return GestureDetector(
                        onTap: () {
                          widget.isOnline == 1
                              ? Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ViewItem(
                                        imageUrl: item['image']!,
                                        name: item['name']!,
                                        price: double.parse(item['price']!),
                                        location: widget.rlocation,
                                        restaurantName: widget.rname,
                                        description: item['description']!,
                                        isVeg: item['vegOrNonVeg'],
                                        rating: item['rating'],
                                        food: widget.food,
                                        quantity: item['quantity'],
                                        unit: item['unit'],
                                        canAdd: canAdd,
                                        distance: distance,
                                      )))
                              : widget.food
                                  ? QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.info,
                                      title: 'Restaurant Offline',
                                      text:
                                          'Restaurant is offline at the moment.',
                                      confirmBtnText: 'Ok',
                                      confirmBtnColor: Colors.orange.shade700,
                                    )
                                  : QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.info,
                                      title: 'Store Offline',
                                      text: 'Store is offline at the moment.',
                                      confirmBtnText: 'Ok',
                                      confirmBtnColor: Colors.orange.shade700,
                                    );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.black12))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    widget.food
                                        ? Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                color:
                                                    item['vegOrNonVeg'] == 'Veg'
                                                        ? Colors.green.shade900
                                                        : Colors.red.shade900,
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: const Icon(
                                              Icons.circle,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const SizedBox(),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      item['name']!.toString().length > 25
                                          ? '${item['name']!.toString().substring(0, 10)}...'
                                          : item['name']!.toString(),
                                      overflow: TextOverflow.clip,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      "₹ ${item['price']!.toString().replaceAll('.00', '')}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.orange.shade700,
                                        ),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          item['rating']!,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          '(2773)',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              fontWeight: FontWeight.w300),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      item['description']!
                                              .split(' ')
                                              .take(4)
                                              .join(' ') +
                                          (item['description']!
                                                      .split(' ')
                                                      .length >
                                                  5
                                              ? '..'
                                              : ''),
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: ColorFiltered(
                                            colorFilter: widget.isOnline == 1
                                                ? const ColorFilter.mode(
                                                    Colors.transparent,
                                                    BlendMode.multiply,
                                                  )
                                                : const ColorFilter.mode(
                                                    Colors.black54,
                                                    BlendMode.darken,
                                                  ),
                                            child: Image.network(
                                              "https://mesme.in/ControlHub/includes/uploads/${item['image']!}",
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        if (widget.isOnline != 1)
                                          Positioned(
                                            top: 8,
                                            left: 5,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade700,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Offline',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          bottom: -10,
                                          left: 15,
                                          right: 15,
                                          child: TextButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                canAdd == true
                                                    ? Colors.orange
                                                    : Colors.grey,
                                              ),
                                              padding: WidgetStatePropertyAll(
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                              ),
                                              shape: WidgetStatePropertyAll(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  side: const BorderSide(
                                                      color: Colors.white,
                                                      width: 2),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              if (canAdd == true) {
                                                FoodFunction.addToCart(
                                                  item['name']!,
                                                  double.parse(item['price']!),
                                                  1,
                                                  item['image']!,
                                                  widget.rname,
                                                  widget.rlocation,
                                                  widget.food
                                                      ? 'Food'
                                                      : 'Grocery',
                                                  context,
                                                );
                                              } else {
                                                QuickAlert.show(
                                                  context: context,
                                                  type: QuickAlertType.info,
                                                  title:
                                                      'Service not Available',
                                                  text:
                                                      'Service is not available in this location.',
                                                  confirmBtnText: 'Ok',
                                                  confirmBtnColor:
                                                      Colors.orange.shade700,
                                                );
                                              }
                                            },
                                            child: const Text(
                                              "Add",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<int>(
        valueListenable: FoodFunction.cartItemCountNotifier,
        builder: (context, itemCount, child) {
          return FloatingActionButton(
            backgroundColor: Colors.orange.shade700,
            onPressed: () {
              Navigator.pushNamed(context, '/FoodCart');
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                if (itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 24,
                        maxHeight: 24,
                      ),
                      child: Center(
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
