import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/price_item_model.dart';
import '../view_model/price_view.model.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PriceViewModel>(context, listen: false).loadAllCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Manage Price List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF013E6A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF013E6A),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF013E6A),
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Regular'),
            Tab(text: 'Express'),
            Tab(text: 'Premium'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ShopkeeperPriceTable(category: 'regular'),
          ShopkeeperPriceTable(category: 'express'),
          ShopkeeperPriceTable(category: 'premium'),
        ],
      ),
    );
  }
}

class ShopkeeperPriceTable extends StatelessWidget {
  final String category;

  const ShopkeeperPriceTable({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    final horizontalPadding = isWeb ? 32.0 : (isTablet ? 24.0 : 16.0);
    
    return Consumer<PriceViewModel>(
      builder: (context, priceProvider, child) {
        if (priceProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFF013E6A),
            ),
          );
        }

        return StreamBuilder<List<PriceItemModel>>(
          stream: priceProvider.streamCategoryItems(category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF013E6A),
                ),
              );
            }

            final items = snapshot.data ?? [];

            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 1400 : double.infinity,
                ),
                child: Column(
                  children: [
                    // Add Button
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 16,
                      ),
                      color: Colors.white,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWeb ? 400 : double.infinity,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showAddEditDialog(context, category, null),
                              icon: Icon(Icons.add),
                              label: Text('Add New Item'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF013E6A),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Items Table
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No items yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap "Add New Item" to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                          : SingleChildScrollView(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                            child: Column(
                              children: [
                                // Table Header
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF013E6A),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Table(
                                    columnWidths: {
                                      0: FlexColumnWidth(2),
                                      1: FlexColumnWidth(2),
                                      2: FlexColumnWidth(2),
                                      3: FlexColumnWidth(2),
                                      4: FixedColumnWidth(70),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          _buildHeaderCell('Item Name'),
                                          _buildHeaderCell('Dry Wash'),
                                          _buildHeaderCell('Wet Wash'),
                                          _buildHeaderCell('Steam Press'),
                                          _buildHeaderCell('Action'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Table Body
                                Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                    3: FlexColumnWidth(2),
                                    4: FixedColumnWidth(60),
                                  },
                                  children: items
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    PriceItemModel item = entry.value;
                                    bool isEven = index % 2 == 0;
                                    return _buildTableRow(
                                      context,
                                      category,
                                      item,
                                      isEven,
                                    );
                                  }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildTableRow(
    BuildContext context,
    String category,
    PriceItemModel item,
    bool isEven,
  ) {
    Color bgColor = isEven ? Colors.grey[50]! : Colors.white;

    return TableRow(
      decoration: BoxDecoration(color: bgColor),
      children: [
        // Item Name
        _buildDataCell(
          item.itemName,
          TextAlign.left,
          fontWeight: FontWeight.w600,
          color: Color(0xFF013E6A),
        ),
        // Dry Wash Price
        _buildPriceCell('₹${item.dryWash}', Colors.blue),
        // Wet Wash Price
        _buildPriceCell('₹${item.wetWash}', Colors.green),
        // Steam Press Price
        _buildPriceCell('₹${item.steamPress}', Colors.orange),
        // Action Menu
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Color(0xFF013E6A),
                size: 24,
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _showAddEditDialog(context, category, item);
                } else if (value == 'delete') {
                  _showDeleteDialog(context, category, item);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCell(
    String text,
    TextAlign align, {
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: fontWeight,
          color: color ?? Colors.black87,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildPriceCell(String price, MaterialColor color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        price,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    String category,
    PriceItemModel? item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddEditPriceDialog(
        category: category,
        item: item,
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String category,
    PriceItemModel item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.itemName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final priceProvider = Provider.of<PriceViewModel>(
                context,
                listen: false,
              );
              final success = await priceProvider.deletePriceItem(
                category,
                item.itemId,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Item deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class AddEditPriceDialog extends StatefulWidget {
  final String category;
  final PriceItemModel? item;

  const AddEditPriceDialog({
    super.key,
    required this.category,
    this.item,
  });

  @override
  State<AddEditPriceDialog> createState() => _AddEditPriceDialogState();
}

class _AddEditPriceDialogState extends State<AddEditPriceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _itemNameController;
  late TextEditingController _dryWashController;
  late TextEditingController _wetWashController;
  late TextEditingController _steamPressController;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(
      text: widget.item?.itemName ?? '',
    );
    _dryWashController = TextEditingController(
      text: widget.item?.dryWash ?? '',
    );
    _wetWashController = TextEditingController(
      text: widget.item?.wetWash ?? '',
    );
    _steamPressController = TextEditingController(
      text: widget.item?.steamPress ?? '',
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _dryWashController.dispose();
    _wetWashController.dispose();
    _steamPressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return AlertDialog(
      title: Text(
        isEdit ? 'Edit Item' : 'Add New Item',
        style: TextStyle(
          color: Color(0xFF013E6A),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: _itemNameController,
                label: 'Item Name',
                hint: 'e.g., Shirt',
                icon: Icons.checkroom,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _dryWashController,
                label: 'Dry Wash Price',
                hint: '0',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _wetWashController,
                label: 'Wet Wash Price',
                hint: '0',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _steamPressController,
                label: 'Steam Press Price',
                hint: '0',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF013E6A),
            foregroundColor: Colors.white,
          ),
          child: Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xFF013E6A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF013E6A), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (keyboardType == TextInputType.number) {
          if (int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
        }
        return null;
      },
    );
  }

  void _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final priceProvider = Provider.of<PriceViewModel>(
      context,
      listen: false,
    );

    final currentItems = priceProvider.getItemsForCategory(widget.category);
    final newOrder = widget.item?.order ?? currentItems.length;

    final item = PriceItemModel(
      itemId: widget.item?.itemId ?? '',
      itemName: _itemNameController.text.trim(),
      dryWash: _dryWashController.text.trim(),
      wetWash: _wetWashController.text.trim(),
      steamPress: _steamPressController.text.trim(),
      order: newOrder,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      updatedAt: widget.item != null ? DateTime.now() : null,
    );

    final success = await priceProvider.savePriceItem(widget.category, item);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.item == null
                ? 'Item added successfully'
                : 'Item updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}