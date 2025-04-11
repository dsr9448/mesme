import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mesme/screens/ViewItem.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:mesme/widgets/calculateLocation.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:mesme/widgets/preloder.dart';

class GroceryItemsApp extends StatefulWidget {
  final List<Map<String, String>> allFoodItems;
  final rname;
  final rlocation;
  final isOnline;
  final userCoordinate;
  final restrauntCoordinate;
  final quantity;
  final unit;
  final time;
  final description;
  final area;
  final restraurantImage;
  final bool food;

  GroceryItemsApp(
      {required this.allFoodItems,
      this.rname,
      this.rlocation,
      this.isOnline,
      this.userCoordinate,
      this.restrauntCoordinate,
      this.quantity,
      this.unit,
      required this.food,
      this.time,
      this.description,
      this.restraurantImage,
      this.area});

  @override
  _GroceryItemsAppState createState() => _GroceryItemsAppState();
}

class _GroceryItemsAppState extends State<GroceryItemsApp> {
  TextEditingController search = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _showAppBarSearch = false;
  String searchQuery = '';

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

  Widget buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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

  Widget build(BuildContext context) {
    Map<String, dynamic> result =
        isWithin6Km(widget.userCoordinate, widget.restrauntCoordinate);

    bool canAdd = result['distance'] <= 6 ? true : false;
    double distance = result['distance'] ?? 0.0;

    List<Map<String, String>> filteredFoodItems = widget.allFoodItems
        .where((item) =>
            item['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    Map<String, List<Map<String, String>>> groupedFoodItems =
        groupBy(filteredFoodItems, (item) => item['category'] ?? 'Others');
    return groupedFoodItems.isEmpty
        ? buildShimmerLoader(false)
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              forceMaterialTransparency: true,
              automaticallyImplyLeading: false,
              leading: IconButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.orange)),
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
                  ? widget.food
                      ? PreferredSize(
                          preferredSize: Size.fromHeight(58),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.shade300, width: 1)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10, top: 10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [],
                                ),
                              ),
                            ),
                          ))
                      : null
                  : null,
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  8), // Ensure rounded corners
                              image: DecorationImage(
                                image: NetworkImage(
                                    widget.restraurantImage), // Network image
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 28),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.45),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.rname.toString().length > 20
                                        ? '${widget.rname.toString().substring(0, 20)}...'
                                        : widget.rname,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white, // Ensure text is readable
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time,
                                      size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    widget.time,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    '${distance.toStringAsFixed(2)} Km ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 14,
                                    child: Icon(Icons.circle,
                                        color: Colors.white, size: 6),
                                  ),
                                  Text(
                                    widget.area,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_showAppBarSearch) buildSearchBar(),
                  if (!_showAppBarSearch)
                    SizedBox(
                      height: 10,
                    ),
                  Column(
                    children: groupedFoodItems.entries.map((entry) {
                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          collapsedBackgroundColor: Colors.white,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          tilePadding: EdgeInsets.symmetric(horizontal: 10),
                          title: Row(
                            children: [
                              widget.food
                                  ? Icon(Icons.restaurant_menu,
                                      color: Colors.orange.shade700)
                                  : Icon(Icons.shopping_bag,
                                      color: Colors.orange.shade700),
                              SizedBox(width: 8),
                              Text(
                                '${entry.key} (${entry.value.length})',
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
                            ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: entry.value
                                  .where(
                                      (item) => item['category'] == entry.key)
                                  .map<Widget>((item) {
                                return GestureDetector(
                                  onTap: () {
                                    if (widget.isOnline == 1) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => ViewItem(
                                                    imageUrl: item['image']!,
                                                    name: item['name']!,
                                                    price: double.parse(
                                                        item['price']!),
                                                    location: widget.rlocation,
                                                    restaurantName:
                                                        widget.rname,
                                                    restrauntCoordinate: widget
                                                        .restrauntCoordinate,
                                                    description:
                                                        item['description']!,
                                                    isVeg: item['vegOrNonVeg'],
                                                    rating: item['rating'],
                                                    food: widget.food,
                                                    quantity: item['quantity'],
                                                    unit: item['unit'],
                                                    stock: item['stock'],
                                                    canAdd: canAdd,
                                                    distance: distance,
                                                  )));
                                    } else {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.info,
                                        title: widget.food
                                            ? 'Restaurant Offline'
                                            : 'Store Offline',
                                        text: widget.food
                                            ? 'Restaurant is offline at the moment.'
                                            : 'Store is offline at the moment.',
                                        confirmBtnText: 'Ok',
                                        confirmBtnColor: Colors.orange.shade700,
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black12))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              widget.food
                                                  ? Container(
                                                      height: 30,
                                                      width: 30,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              item['vegOrNonVeg'] ==
                                                                      'Veg'
                                                                  ? Colors.green
                                                                      .shade900
                                                                  : Colors.red
                                                                      .shade900,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8)),
                                                      child: const Icon(
                                                        Icons.circle,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                              const SizedBox(height: 6),
                                              Text(
                                                item['name']!.length > 20
                                                    ? '${item['name']!.substring(0, 16)}...'
                                                    : item['name']!,
                                                overflow: TextOverflow.clip,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                "₹ ${item['price']!.replaceAll('.00', '')}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w900),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item['description']!
                                                        .split(' ')
                                                        .take(3)
                                                        .join(' ') +
                                                    (item['description']!
                                                                .split(' ')
                                                                .length >
                                                            5
                                                        ? '..'
                                                        : ''),
                                                style: const TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                        BorderRadius.circular(
                                                            15),
                                                    child: ColorFiltered(
                                                      colorFilter: widget
                                                                  .isOnline ==
                                                              1
                                                          ? const ColorFilter
                                                              .mode(
                                                              Colors
                                                                  .transparent,
                                                              BlendMode
                                                                  .multiply)
                                                          : const ColorFilter
                                                              .mode(
                                                              Colors.black54,
                                                              BlendMode.darken),
                                                      child: Image.network(
                                                        "https://admin.maximus.works/admin/menu/${item['image']!}",
                                                        width: 150,
                                                        height: 150,
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
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .orange.shade700,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: const Text(
                                                          'Offline',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  widget.isOnline == 1
                                                      ? Positioned(
                                                          bottom: -10,
                                                          left: 15,
                                                          right: 15,
                                                          child: TextButton(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  WidgetStatePropertyAll(
                                                                canAdd
                                                                    ? Colors
                                                                        .orange
                                                                    : Colors
                                                                        .grey,
                                                              ),
                                                            ),
                                                            onPressed: canAdd
                                                                ? () =>
                                                                    FoodFunction
                                                                        .addToCart(
                                                                      item[
                                                                          'name']!,
                                                                      double.parse(
                                                                          item[
                                                                              'price']!),
                                                                      1,
                                                                      item[
                                                                          'image']!,
                                                                      widget
                                                                          .rname,
                                                                      widget
                                                                          .rlocation,
                                                                      widget
                                                                          .restrauntCoordinate,
                                                                      widget.food
                                                                          ? 'Food'
                                                                          : 'Grocery',
                                                                      "",
                                                                      "",
                                                                      "",
                                                                      context,
                                                                    )
                                                                : () =>
                                                                    QuickAlert
                                                                        .show(
                                                                      context:
                                                                          context,
                                                                      type: QuickAlertType
                                                                          .info,
                                                                      title:
                                                                          'Service not Available',
                                                                      text:
                                                                          'Service is not available in this location.',
                                                                      confirmBtnText:
                                                                          'Ok',
                                                                      confirmBtnColor: Colors
                                                                          .orange
                                                                          .shade700,
                                                                    ),
                                                            child: const Text(
                                                              "Add",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
