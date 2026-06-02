import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/controlador_login.dart';
import 'package:spin_flow/controller/controlador_checkin_aluno.dart';
import 'package:spin_flow/controller/controlador_recuperacao_senha.dart';
import 'package:spin_flow/controller/controlador_grupo_alunos.dart';
import 'package:spin_flow/controller/controlador_manutencao.dart';
import 'package:spin_flow/controller/controlador_sala.dart';
import 'package:spin_flow/controller/controlador_turma.dart';
import 'package:spin_flow/controller/controlador_artista_banda.dart';
import 'package:spin_flow/controller/controlador_mix.dart';
import 'package:spin_flow/controller/controlador_musica.dart';
import 'package:spin_flow/controller/controlador_operacao_aula.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aluno.dart';
import 'package:spin_flow/infra/database/dao/i_dao_artista_banda.dart';
import 'package:spin_flow/infra/database/dao/i_dao_bike.dart';
import 'package:spin_flow/infra/database/dao/i_dao_categoria_musica.dart';
import 'package:spin_flow/infra/database/dao/i_dao_checkin.dart';
import 'package:spin_flow/infra/database/dao/i_dao_fila_espera_checkin.dart';
import 'package:spin_flow/infra/database/dao/i_dao_grupo_alunos.dart';
import 'package:spin_flow/infra/database/dao/i_dao_manutencao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_mix.dart';
import 'package:spin_flow/infra/database/dao/i_dao_musica.dart';
import 'package:spin_flow/infra/database/dao/i_dao_posicao_bike.dart';
import 'package:spin_flow/infra/database/dao/i_dao_sala.dart';
import 'package:spin_flow/infra/database/dao/i_dao_tipo_manutencao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_turma.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aula_realizada.dart';
import 'package:spin_flow/infra/database/dao/i_dao_avaliacao_musica.dart';
import 'package:spin_flow/infra/database/dao/i_dao_turma_mix.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_aula_realizada_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_avaliacao_musica_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_turma_mix_sqlite.dart';
import 'package:spin_flow/infra/database/dao/i_dao_usuario.dart';
import 'package:spin_flow/infra/database/dao/i_dao_video_aula.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_aluno_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_artista_banda_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_bike_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_categoria_musica_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_checkin_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_fila_espera_checkin_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_grupo_alunos_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_manutencao_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_mix_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_musica_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_posicao_bike_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_sala_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_tipo_manutencao_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_turma_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_usuario_sqlite.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_video_aula_sqlite.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_aluno.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_artista_banda.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_autenticacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_checkin_aluno.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_grupo_alunos.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_manutencao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_mix.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_musica.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_operacao_aula.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_recuperacao_senha.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_sala.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_turma.dart';

final getIt = GetIt.instance;

void configurarDependencias() {
  // DAOs — autenticacao
  getIt.registerLazySingleton<IDAOUsuario>(() => DAOUsuarioSQLite());
  getIt.registerLazySingleton<IDAOAluno>(() => DAOAlunoSQLite());

  // DAOs — repertorio
  getIt.registerLazySingleton<IDAOArtistaBanda>(() => DAOArtistaBandaSQLite());
  getIt.registerLazySingleton<IDAOCategoriaMusica>(
    () => DAOCategoriaMusicaSQLite(),
  );
  getIt.registerLazySingleton<IDAOVideoAula>(() => DAOVideoAulaSQLite());
  getIt.registerLazySingleton<IDAOMusica>(() => DAOMusicaSQLite());
  getIt.registerLazySingleton<IDAOMix>(() => DAOMixSQLite());

  // DAOs — gestao administrativa
  getIt.registerLazySingleton<IDAOSala>(() => DAOSalaSQLite());
  getIt.registerLazySingleton<IDAOBike>(() => DAOBikeSQLite());
  getIt.registerLazySingleton<IDAOManutencao>(() => DAOManutencaoSQLite());
  getIt.registerLazySingleton<IDAOTipoManutencao>(
    () => DAOTipoManutencaoSQLite(),
  );
  getIt.registerLazySingleton<IDAOTurma>(() => DAOTurmaSQLite());
  getIt.registerLazySingleton<IDAOGrupoAlunos>(
    () => DAOGrupoAlunosSQLite(daoAluno: getIt<IDAOAluno>()),
  );

  // DAOs — check-in
  getIt.registerLazySingleton<IDAOPosicaoBike>(() => DAOPosicaoBikeSQLite());
  getIt.registerLazySingleton<IDAOCheckin>(() => DAOCheckinSQLite());
  getIt.registerLazySingleton<IDAOFilaEsperaCheckin>(
    () => DAOFilaEsperaCheckinSQLite(),
  );
  getIt.registerLazySingleton<IDAOTurmaMix>(() => DAOTurmaMixSQLite());
  getIt.registerLazySingleton<IDAOAvaliacaoMusica>(
    () => DAOAvaliacaoMusicaSQLite(),
  );
  getIt.registerLazySingleton<IDAOAulaRealizada>(
    () => DAOAulaRealizadaSQLite(),
  );

  // ── Repositórios ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton(() => RepositorioAluno());
  getIt.registerLazySingleton(() => RepositorioAutenticacao());
  getIt.registerLazySingleton(() => RepositorioRecuperacaoSenha());
  getIt.registerLazySingleton(() => RepositorioSala());
  getIt.registerLazySingleton(() => RepositorioTurma());
  getIt.registerLazySingleton(() => RepositorioManutencao());
  getIt.registerLazySingleton(() => RepositorioGrupoAlunos());
  getIt.registerLazySingleton(() => RepositorioArtistaBanda());
  getIt.registerLazySingleton(() => RepositorioMusica());
  getIt.registerLazySingleton(() => RepositorioMix());
  getIt.registerLazySingleton(() => RepositorioOperacaoAula());
  getIt.registerLazySingleton(() => RepositorioCheckinAluno());

  // ── Controllers ───────────────────────────────────────────────────────────
  getIt.registerFactory(() => ControladorLogin());
  getIt.registerFactory(() => ControladorRecuperacaoSenha());
  getIt.registerFactory(() => ControladorSala());
  getIt.registerFactory(() => ControladorManutencao());
  getIt.registerFactory(() => ControladorTurma());
  getIt.registerFactory(() => ControladorGrupoAlunos());
  getIt.registerFactory(() => ControladorArtistaBanda());
  getIt.registerFactory(() => ControladorMusica());
  getIt.registerFactory(() => ControladorMix());
  getIt.registerFactory(() => ControladorOperacaoAula());
  getIt.registerFactory(() => ControladorCheckinAluno());
}
