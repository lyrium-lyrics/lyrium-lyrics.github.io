import 'package:drift/drift.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/utils/search_terms.dart';
import 'package:lyrium/utils/string.dart';

part 'local.g.dart';

class Lyrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get namespace => text().withDefault(Constant("originid"))();
  TextColumn get originId => text().nullable()();
  IntColumn get interlinked => integer().nullable().references(Lyrics, #id)();
  IntColumn get language => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  RealColumn get duration =>
      real()(); // seconds.milliseconds as double (e.g. 15.123)
  BoolColumn get instrumental => boolean().nullable()();
  IntColumn get lyricsVersion => integer().withDefault(const Constant(-1))();
  TextColumn get lyrics => text().nullable()();
  TextColumn get attachments => text().nullable()();
}

@DriftDatabase(tables: [Lyrics])
class AppDatabase extends _$AppDatabase {
  final String name;

  AppDatabase({QueryExecutor? exec, this.name = "lyrium"})
    : super(exec ?? openConnection(name));

  factory AppDatabase.memory() {
    return AppDatabase(exec: openConnection("name", memoryMode: true));
  }
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from == 1 && to == 2) {
        await migrator.addColumn(lyrics, lyrics.namespace);
      }
    },
  );
}

extension LyricsDatabase on AppDatabase {
  Future<List<Lyric>> all() {
    return (select(lyrics)..orderBy([
          (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
          (u) => OrderingTerm(expression: u.id),
        ]))
        .get();
  }

  Expression<bool> buildSearchFilter(SearchTerms terms) {
    final conditions = <Expression<bool>>[];

    if (terms.firstTerm.isValid) {
      conditions.add(lyrics.title.like('%${terms.firstTerm!}%'));
    }

    if (terms.firstTerm.isValid) {
      conditions.add(lyrics.title.like('%${terms.firstTerm!}%'));
    }

    for (final q in terms.quotedTerms) {
      if (q.isValid) {
        conditions.add(lyrics.lyrics.like('%$q%'));
      }
    }

    conditions.add(lyrics.interlinked.isNull());

    // // any unquoted extras
    // for (final u in terms.unquotedExtras) {
    //   conditions.add(
    //     name.like('%$u%') | description.like('%$u%')
    //   );
    // }

    return conditions.fold(const Constant(true), (prev, expr) => prev & expr);
  }
}
