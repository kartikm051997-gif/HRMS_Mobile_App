import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/payroll_provider/Mispunch_Reports_Provider.dart';
import '../../../widgets/custom_textfield/custom_dropdown_with_search.dart';

class MisPunchReportsScreen extends StatefulWidget {
  const MisPunchReportsScreen({super.key});

  @override
  State<MisPunchReportsScreen> createState() => _MisPunchReportsScreenState();
}

class _MisPunchReportsScreenState extends State<MisPunchReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _searchFocusNode.unfocus();
        final dayFilter = _getDayFilterFromIndex(_tabController.index);
        context.read<MisPunchReportsProvider>().fetchReports(dayFilter);
      }
    });

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  int _getDayFilterFromIndex(int index) {
    switch (index) {
      case 0:
        return 3;
      case 1:
        return 2;
      case 2:
        return 1;
      default:
        return 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "MisPunch Reports"),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            // 🔹 Location Dropdown + Go Button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<MisPunchReportsProvider>(
                    builder: (context, provider, child) {
                      return CustomSearchDropdownWithSearch(
                        isMandatory: true,
                        labelText: "Location",
                        items: provider.locations,
                        selectedValue: provider.selectedLocation,
                        onChanged: (value) {
                          if (value != null) {
                            provider.setSelectedLocation(value);
                            provider.setHasSearched(
                              false,
                            ); // reset when location changes
                          }
                        },
                        hintText: "Please select location",
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _searchFocusNode.unfocus();
                        final provider =
                            context.read<MisPunchReportsProvider>();

                        if (provider.selectedLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select a location first"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final dayFilter = _getDayFilterFromIndex(
                          _tabController.index,
                        );
                        provider.fetchReports(dayFilter);
                        provider.setHasSearched(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Go",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Conditional content
            Expanded(
              child: Consumer<MisPunchReportsProvider>(
                builder: (context, provider, child) {
                  if (!provider.hasSearched) {
                    return const Center(
                      child: Text(
                        "Please select a location view reports",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFonts.poppins,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        // 🔹 Tab Bar
                        Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor2.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColor.primaryColor2,
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey[600],
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(
                                child: Text(
                                  'Last 3 Days',
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Last 2 Days',
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Today',
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 🔹 PDF Button
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Consumer<MisPunchReportsProvider>(
                            builder: (context, provider, child) {
                              final isGeneratingPDF = provider.isDownloading;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      isGeneratingPDF
                                          ? null
                                          : () async {
                                            _searchFocusNode.unfocus();
                                            final success =
                                                await provider
                                                    .generateOverallPDF();
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    success
                                                        ? "Overall PDF report generated and opened successfully"
                                                        : "Failed to generate PDF report",
                                                  ),
                                                  backgroundColor:
                                                      success
                                                          ? Colors.green
                                                          : Colors.red,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          },
                                  icon:
                                      isGeneratingPDF
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : const Icon(
                                            Icons.picture_as_pdf,
                                            size: 20,
                                          ),
                                  label: Text(
                                    isGeneratingPDF
                                        ? "Generating PDF..."
                                        : "Generate Overall PDF Report",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColor.primaryColor2,
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // 🔹 Search Bar
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              context
                                  .read<MisPunchReportsProvider>()
                                  .searchReports(value);
                            },
                            onSubmitted: (_) => _searchFocusNode.unfocus(),
                            decoration: InputDecoration(
                              hintText: "Search employees, ID, designation...",
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontFamily: AppFonts.poppins,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                              ),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          context
                                              .read<MisPunchReportsProvider>()
                                              .searchReports('');
                                          _searchFocusNode.unfocus();
                                        },
                                      )
                                      : null,
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColor.primaryColor2,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),

                        // 🔹 Reports Content
                        SizedBox(
                          height:
                              isKeyboardVisible
                                  ? MediaQuery.of(context).size.height * 0.4
                                  : MediaQuery.of(context).size.height * 0.6,
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildReportsView(),
                              _buildReportsView(),
                              _buildReportsView(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsView() {
    return Consumer<MisPunchReportsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.filteredReports.isEmpty) {
          return Center(
            child: Text(
              provider.searchQuery.isNotEmpty
                  ? "No matching records found"
                  : "No mispunch reports found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.poppins,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.filteredReports.length,
          itemBuilder: (context, index) {
            final report = provider.filteredReports[index];
            return Card(
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.grey.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor2.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppColor.primaryColor2,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFonts.poppins,
                                  color: Color(0xFF1A202C),
                                ),
                              ),
                              Text(
                                "ID: ${report.empId}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: AppFonts.poppins,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow("Designation", report.designation),
                    _buildInfoRow("Date", report.date),
                    _buildInfoRow(
                      "In Time",
                      report.inTime.isEmpty ? "Not Punched" : report.inTime,
                    ),
                    _buildInfoRow(
                      "Out Time",
                      report.outTime.isEmpty ? "Not Punched" : report.outTime,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.poppins,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
