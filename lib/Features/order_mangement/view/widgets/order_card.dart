import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../model/shedule_model.dart';

class ShopkeeperOrderCard extends StatelessWidget {
  final ScheduleModel schedule;
  final String customerName;
  final VoidCallback onModify;

  const ShopkeeperOrderCard({
    super.key,
    required this.schedule,
    required this.customerName,
    required this.onModify,
  });

  Color _getStatusColor() {
    switch (schedule.status.toLowerCase()) {
      case 'paid':
        return PColors.successGreen;
      case 'cancelled':
        return PColors.errorRed;
      case 'delivered':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      default:
        return PColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PColors.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: PColors.primaryColor.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Left side - Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: PColors.primaryColor),
                      SizedBox(width: 6),
                      Text(
                        'Order by $customerName',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: PColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // Schedule ID
                  Text(
                    'Schedule ID: ${schedule.scheduleId.substring(0, 8)}...',
                    style: TextStyle(
                      fontSize: 12,
                      color: PColors.darkGray.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 4),
                  
                  // Ordered date
                  Text(
                    'Ordered: ${DateFormat('d MMM yyyy').format(schedule.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: PColors.darkGray.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 4),
                  
                  // Scheduled date
                  Text(
                    'Scheduled: ${DateFormat('d MMM yyyy').format(schedule.pickupDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: PColors.darkGray.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      schedule.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 12),
            
            // Right side - Modify button
            ElevatedButton(
              onPressed: onModify,
              style: ElevatedButton.styleFrom(
                backgroundColor: PColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
              child: Text(
                'Modify',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
