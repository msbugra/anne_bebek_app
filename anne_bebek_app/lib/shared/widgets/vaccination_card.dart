import 'package:flutter/material.dart';
import '../models/vaccination_model.dart';

class VaccinationCard extends StatelessWidget {
  final VaccinationModel vaccination;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkCompleted;
  final bool showActions;
  final bool isCompact;

  const VaccinationCard({
    super.key,
    required this.vaccination,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onMarkCompleted,
    this.showActions = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 16, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              if (!isCompact) ...[
                const SizedBox(height: 8),
                _buildDetails(context),
              ],
              if (vaccination.notes != null && !isCompact) ...[
                const SizedBox(height: 8),
                _buildNotes(context),
              ],
              if (showActions && !isCompact) ...[
                const SizedBox(height: 12),
                _buildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: isCompact ? 20 : 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vaccination.vaccineName,
                style: TextStyle(
                  fontSize: isCompact ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${vaccination.doseNumber}. Doz',
                    style: TextStyle(
                      fontSize: isCompact ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vaccination.statusDisplayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isCompact ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isCompact) _buildDateInfo(context),
      ],
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    final theme = Theme.of(context);
    final dateColor = vaccination.isDelayed
        ? Colors.red[600]
        : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatDate(vaccination.scheduledDate),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: dateColor,
          ),
        ),
        if (vaccination.administeredDate != null) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 12, color: Colors.green[600]),
              const SizedBox(width: 4),
              Text(
                _formatDate(vaccination.administeredDate!),
                style: TextStyle(fontSize: 12, color: Colors.green[600]),
              ),
            ],
          ),
        ],
        if (vaccination.isDelayed) ...[
          const SizedBox(height: 2),
          Text(
            '${vaccination.delayDays} gün gecikme',
            style: TextStyle(
              fontSize: 11,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vaccination.location != null) ...[
          _buildDetailRow(Icons.location_on, 'Lokasyon', vaccination.location!),
          const SizedBox(height: 4),
        ],
        if (vaccination.administeredDate != null) ...[
          _buildDetailRow(
            Icons.event_available,
            'Yapıldığı Tarih',
            _formatDate(vaccination.administeredDate!),
          ),
          const SizedBox(height: 4),
        ],
        _buildDetailRow(
          Icons.schedule,
          'Planlanan Tarih',
          _formatDate(vaccination.scheduledDate),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildNotes(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, size: 16, color: Colors.blue[600]),
              const SizedBox(width: 6),
              Text(
                'Notlar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            vaccination.notes!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[800],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        if (!vaccination.isCompleted && onMarkCompleted != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onMarkCompleted,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Tamamlandı', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (onEdit != null) ...[
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, size: 20, color: Colors.blue[600]),
            tooltip: 'Düzenle',
          ),
        ],
        if (onDelete != null) ...[
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete, size: 20, color: Colors.red[600]),
            tooltip: 'Sil',
          ),
        ],
      ],
    );
  }

  Color _getStatusColor() {
    switch (vaccination.status) {
      case VaccineStatus.completed:
        return Colors.green;
      case VaccineStatus.scheduled:
        return vaccination.isDelayed ? Colors.red : Colors.blue;
      case VaccineStatus.delayed:
        return Colors.orange;
      case VaccineStatus.skipped:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (vaccination.status) {
      case VaccineStatus.completed:
        return Icons.check_circle;
      case VaccineStatus.scheduled:
        return vaccination.isDelayed ? Icons.warning : Icons.schedule;
      case VaccineStatus.delayed:
        return Icons.warning;
      case VaccineStatus.skipped:
        return Icons.block;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class VaccinationTimeline extends StatelessWidget {
  final List<VaccinationModel> vaccinations;
  final VoidCallback? onAddVaccination;
  final Function(VaccinationModel)? onVaccinationTap;
  final Function(VaccinationModel)? onVaccinationEdit;
  final Function(VaccinationModel)? onVaccinationDelete;
  final Function(VaccinationModel)? onMarkCompleted;

  const VaccinationTimeline({
    super.key,
    required this.vaccinations,
    this.onAddVaccination,
    this.onVaccinationTap,
    this.onVaccinationEdit,
    this.onVaccinationDelete,
    this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (vaccinations.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort vaccinations by scheduled date
    final sortedVaccinations = List<VaccinationModel>.from(vaccinations)
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return Column(
      children: [
        ...sortedVaccinations.asMap().entries.map((entry) {
          final index = entry.key;
          final vaccination = entry.value;

          return Column(
            children: [
              if (index == 0) _buildTimelineStart(),
              _buildTimelineItem(
                context,
                vaccination,
                index == sortedVaccinations.length - 1,
              ),
            ],
          );
        }),
        if (onAddVaccination != null) ...[
          const SizedBox(height: 16),
          _buildAddButton(context),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vaccines, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz aşı kaydı bulunmuyor',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk aşı kaydınızı ekleyin',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (onAddVaccination != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddVaccination,
              icon: const Icon(Icons.add),
              label: const Text('Aşı Ekle'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineStart() {
    return Container(height: 20, width: 2, color: Colors.grey[300]);
  }

  Widget _buildTimelineItem(
    BuildContext context,
    VaccinationModel vaccination,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getTimelineItemColor(vaccination),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 100, // Height will be adjusted by IntrinsicHeight
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: VaccinationCard(
                vaccination: vaccination,
                onTap: onVaccinationTap != null
                    ? () => onVaccinationTap!(vaccination)
                    : null,
                onEdit: onVaccinationEdit != null
                    ? () => onVaccinationEdit!(vaccination)
                    : null,
                onDelete: onVaccinationDelete != null
                    ? () => onVaccinationDelete!(vaccination)
                    : null,
                onMarkCompleted: onMarkCompleted != null
                    ? () => onMarkCompleted!(vaccination)
                    : null,
                isCompact: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: onAddVaccination,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Aşı Ekle'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Color _getTimelineItemColor(VaccinationModel vaccination) {
    switch (vaccination.status) {
      case VaccineStatus.completed:
        return Colors.green;
      case VaccineStatus.scheduled:
        return vaccination.isDelayed ? Colors.red : Colors.blue;
      case VaccineStatus.delayed:
        return Colors.orange;
      case VaccineStatus.skipped:
        return Colors.grey;
    }
  }
}

// Mini vaccination card for dashboard summaries
class VaccinationMiniCard extends StatelessWidget {
  final VaccinationModel vaccination;
  final VoidCallback? onTap;

  const VaccinationMiniCard({super.key, required this.vaccination, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getStatusIcon(), size: 16, color: _getStatusColor()),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    vaccination.vaccineName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${vaccination.doseNumber}. Doz',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(vaccination.scheduledDate),
              style: TextStyle(
                fontSize: 10,
                color: vaccination.isDelayed
                    ? Colors.red[600]
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (vaccination.status) {
      case VaccineStatus.completed:
        return Colors.green;
      case VaccineStatus.scheduled:
        return vaccination.isDelayed ? Colors.red : Colors.blue;
      case VaccineStatus.delayed:
        return Colors.orange;
      case VaccineStatus.skipped:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (vaccination.status) {
      case VaccineStatus.completed:
        return Icons.check_circle;
      case VaccineStatus.scheduled:
        return vaccination.isDelayed ? Icons.warning : Icons.schedule;
      case VaccineStatus.delayed:
        return Icons.warning;
      case VaccineStatus.skipped:
        return Icons.block;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
