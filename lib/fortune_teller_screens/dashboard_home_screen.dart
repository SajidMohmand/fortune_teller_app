import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fortune_teller_app/fortune_teller_screens/widgets/question_list.dart';
import 'package:fortune_teller_app/screens/home_main_screen.dart';

import 'model/question.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<Question>> getQuestionsByStatus(String status) {
    return FirebaseFirestore.instance
        .collectionGroup('questions') // 🔥 gets from ALL users
        .where('status', isEqualTo: status)
        .orderBy('askedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Question.fromFirestore(doc))
          .toList();
    });
  }

  Widget _questionsTab(String status) {
    return StreamBuilder<List<Question>>(
      stream: getQuestionsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No questions'));
        }

        return QuestionList(questions: snapshot.data!);
      },
    );
  }


  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // close dialog
                await _logoutAndRedirect(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutAndRedirect(BuildContext context) async {

   Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeMainScreen(),
      ),
          (route) => false,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Waiting for Info'),
            Tab(text: 'Answered'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _questionsTab('pending'),
          _questionsTab('waiting'),
          _questionsTab('answered'),
        ],
      ),

    );
  }

  // List<Question> _generateSampleQuestions({required String status}) {
  //   return [
  //     Question(
  //       id: '1',
  //       userName: 'Alex Johnson',
  //       questionText:
  //       'I\'m having trouble understanding how to implement the new API endpoints...',
  //       status: status,
  //       askedDate: DateTime.now().subtract(const Duration(hours: 2)),
  //     ),
  //     Question(
  //       id: '2',
  //       userName: 'Sam Wilson',
  //       questionText:
  //       'Could you clarify the authentication flow for mobile users?',
  //       status: status,
  //       askedDate: DateTime.now().subtract(const Duration(days: 1)),
  //     ),
  //     Question(
  //       id: '3',
  //       userName: 'Taylor Chen',
  //       questionText:
  //       'Regarding the database migration, what\'s the best approach for...',
  //       status: status,
  //       askedDate: DateTime.now().subtract(const Duration(days: 3)),
  //     ),
  //   ];
  // }
}