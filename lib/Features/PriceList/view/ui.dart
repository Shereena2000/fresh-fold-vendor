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

            return Column(
              children: [
                // Add Button
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
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

                // Items List
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
                      : ReorderableListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: items.length,
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) newIndex--;
                            final reorderedItems = List<PriceItemModel>.from(items);
                            final item = reorderedItems.removeAt(oldIndex);
                            reorderedItems.insert(newIndex, item);
                            priceProvider.reorderItems(category, reorderedItems);
                          },
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _buildItemCard(context, category, item, index);
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    String category,
    PriceItemModel item,
    int index,
  ) {
    return Card(
      key: ValueKey(item.itemId),
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Color(0xFF013E6A),
          child: Icon(Icons.drag_handle, color: Colors.white),
        ),
        title: Text(
          item.itemName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF013E6A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceRow('Dry Wash', item.dryWash),
              SizedBox(height: 4),
              _buildPriceRow('Wet Wash', item.wetWash),
              SizedBox(height: 4),
              _buildPriceRow('Steam Press', item.steamPress),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
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
                  Icon(Icons.edit, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '₹$price',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
      ],
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