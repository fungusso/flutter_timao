import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timao/database/db_firestore.dart';
import 'package:flutter_timao/pages/edit_titulo_page.dart';
import 'package:flutter_timao/repositories/times_repository.dart';
import 'package:flutter_timao/widgets/brasao.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../models/times.dart';
import './add_titulo_page.dart';

class TimePage extends StatefulWidget {
  final Time time;
  const TimePage({Key key, this.time}) : super(key: key);

  @override
  _TimePageState createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  FirebaseFirestore db;
  Stream<DocumentSnapshot> torcedoresSnapshot;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore db = DBFirestore.get();
    torcedoresSnapshot = db.doc('times/${widget.time.id}').snapshots();
  }

  tituloPage() {
    Get.to(() => AddTituloPage(time: widget.time));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.time.cor,
          title: Text(widget.time.nome),
          actions: [IconButton(icon: const Icon(Icons.add), onPressed: tituloPage)],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.stacked_line_chart),
                text: 'Estatísticas',
              ),
              Tab(
                icon: Icon(Icons.emoji_events),
                text: 'Títulos',
              ),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Brasao(
                  image: widget.time.brasao,
                  width: 250,
                ),
              ),
              Text(
                'Pontos: ${widget.time.pontos}',
                style: const TextStyle(fontSize: 22),
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: torcedoresSnapshot,
                builder: (context, snapshot) {
                  final torcedores =
                  (snapshot.data.exists) ? snapshot.data['torcedores'] : 0;
                  return Text(
                    'Torcedores: $torcedores',
                    style: const TextStyle(fontSize: 22),
                  );
                },
              ),
            ],
          ),
          titulos()
        ]),
      ),
    );
  }

  Widget titulos() {
    final time = Provider.of<TimesRepository>(context)
        .times
        .firstWhere((t) => t.nome == widget.time.nome);

    final quantidade = time.titulos.length;

    return quantidade == 0
        ? Container(
      child: const Center(
        child: Text('Nenhum Titulo Ainda!'),
      ),
    )
        : ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const Icon(Icons.emoji_events),
          title: Text(time.titulos[index].campeonato),
          trailing: Text(time.titulos[index].ano),
          onTap: () {
            Get.to(
                  () => EditTituloPage(titulo: time.titulos[index]),
              fullscreenDialog: true,
            );
          },
        );
      },
      separatorBuilder: (_, __) => const Divider(),
      itemCount: quantidade,
    );
  }
}