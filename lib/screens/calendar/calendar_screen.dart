import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/habit.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isLoading=true;
  DateTime _currentMonth=DateTime.now();

  final DatabaseService _db = DatabaseService();

  //取得した習慣を入れるリスト(Habit型限定)
  List<Habit> _habits=[];

  @override
  void initState(){
    super.initState();
  }

  //すべての習慣をデータベースから取得
  Future<void> _loadData()async{
    //時間がかかるからロード処理
    setState(()=> _isLoading=true);

    try{
      final habitsData=await _db.getAllHabits();

      //lengthを使うためにListに格納
      _habits=habitsData;

    } catch(e){
      if(mounted){
        _showSnackBar('エラーが発生しました:$e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('calendar')),
      body:_isLoading ? const Center(child:CircularProgressIndicator())
                      : _buildCalendarView(),
    );
  }

  Widget _buildCalendarView(){
    //カレンダー表示
    return const Center(child: Text("カレンダー"));
  }
}
