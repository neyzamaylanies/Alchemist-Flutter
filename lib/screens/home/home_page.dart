// lib/screens/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/equipment/equipment_list_bloc.dart';
import '../../blocs/transaction/transaction_list_bloc.dart';
import '../../blocs/student/student_list_bloc.dart';
import '../../repositories/equipment_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/student_repository.dart';
import '../../utils/remote_helper.dart';
import '../../utils/app_theme.dart';
import '../equipment/equipment_list_page.dart';
import '../transaction/transaction_list_page.dart';
import '../student/student_list_page.dart';
import 'widgets/dashboard_card_widget.dart';
import 'widgets/summary_stat_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ThemeData _theme;

  final EquipmentListBloc _equipmentBloc = EquipmentListBloc(
    equipmentRepository: EquipmentRepository(RemoteHelper.getDio()),
  );
  final TransactionListBloc _transactionBloc = TransactionListBloc(
    transactionRepository: TransactionRepository(RemoteHelper.getDio()),
  );
  final StudentListBloc _studentBloc = StudentListBloc(
    studentRepository: StudentRepository(RemoteHelper.getDio()),
  );

  @override
  void initState() {
    super.initState();
    _equipmentBloc.add(LoadEquipmentListEvent());
    _transactionBloc.add(LoadTransactionListEvent());
    _studentBloc.add(LoadStudentListEvent());
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<EquipmentListBloc>(create: (_) => _equipmentBloc),
        BlocProvider<TransactionListBloc>(create: (_) => _transactionBloc),
        BlocProvider<StudentListBloc>(create: (_) => _studentBloc),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.navyDark,
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo/LogoAlchemist.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 10),
              const Text(
                "Alchemist",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ringkasan",
                    style: _theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildSummaryRow(),
                const SizedBox(height: 24),
                Text("Menu",
                    style: _theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildMenuGrid(context),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Transaksi Terbaru",
                        style: _theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => _navigateTo(
                          context,
                          TransactionListPage(
                              transactionBloc: _transactionBloc)),
                      child: const Text("Lihat semua"),
                    ),
                  ],
                ),
                _buildRecentTransactions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return BlocBuilder<EquipmentListBloc, EquipmentListState>(
      builder: (context, state) {
        int totalEquipment = 0;
        int available = 0;
        int damaged = 0;

        if (state is EquipmentListLoaded) {
          totalEquipment = state.equipments.length;
          available = state.equipments
              .where((e) => e.conditionStatus == "BAIK")
              .length;
          damaged = state.equipments
              .where((e) =>
                  e.conditionStatus == "RUSAK_BERAT" ||
                  e.conditionStatus == "RUSAK_RINGAN")
              .length;
        }

        return Row(
          children: [
            Expanded(
              child: SummaryStatWidget(
                label: "Total Alat",
                value: totalEquipment.toString(),
                icon: Icons.science,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SummaryStatWidget(
                label: "Tersedia",
                value: available.toString(),
                icon: Icons.check_circle,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SummaryStatWidget(
                label: "Rusak",
                value: damaged.toString(),
                icon: Icons.warning,
                color: AppTheme.error,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      primary: false,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        DashboardCardWidget(
          title: "Alat Lab",
          subtitle: "Kelola inventaris",
          icon: Icons.science,
          color: AppTheme.primary,
          onTap: () => _navigateTo(
              context, EquipmentListPage(equipmentBloc: _equipmentBloc)),
        ),
        DashboardCardWidget(
          title: "Peminjaman",
          subtitle: "Catat transaksi",
          icon: Icons.swap_horiz,
          color: AppTheme.primaryLight,
          onTap: () => _navigateTo(
              context,
              TransactionListPage(transactionBloc: _transactionBloc)),
        ),
        DashboardCardWidget(
          title: "Mahasiswa",
          subtitle: "Data peminjam",
          icon: Icons.people,
          color: AppTheme.accent,
          onTap: () => _navigateTo(
              context, StudentListPage(studentBloc: _studentBloc)),
        ),
        DashboardCardWidget(
          title: "Kondisi Alat",
          subtitle: "Riwayat kondisi",
          icon: Icons.history,
          color: AppTheme.accentLight,
          onTap: () => _showComingSoon(context),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return BlocBuilder<TransactionListBloc, TransactionListState>(
      builder: (context, state) {
        if (state is TransactionListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransactionListLoaded) {
          final recent = state.transactions.take(5).toList();
          if (recent.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text("Belum ada transaksi")),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: recent.length,
            itemBuilder: (context, index) {
              final t = recent[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: t.isPeminjaman
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    child: Icon(
                      t.isPeminjaman
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color:
                          t.isPeminjaman ? Colors.orange : Colors.green,
                    ),
                  ),
                  title: Text(t.equipmentId,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(t.typeLabel),
                  trailing: Text("${t.quantity}x",
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fitur segera hadir!")),
    );
  }
}