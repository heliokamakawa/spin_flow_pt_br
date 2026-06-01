import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/autenticacao/controlador_login.dart';
import 'package:spin_flow/controller/checkin/controlador_checkin_aluno.dart';
import 'package:spin_flow/controller/controlador_recuperacao_senha.dart';
import 'package:spin_flow/controller/gestao_administrativa/controlador_grupo_alunos.dart';
import 'package:spin_flow/controller/gestao_administrativa/controlador_manutencao.dart';
import 'package:spin_flow/controller/gestao_administrativa/controlador_sala.dart';
import 'package:spin_flow/controller/gestao_administrativa/controlador_turma.dart';
import 'package:spin_flow/controller/gestao_aula/controlador_artista_banda.dart';
import 'package:spin_flow/controller/gestao_aula/controlador_mix.dart';
import 'package:spin_flow/controller/gestao_aula/controlador_musica.dart';
import 'package:spin_flow/controller/gestao_aula/controlador_operacao_aula.dart';
import 'package:spin_flow/model/dao/i_dao_aluno.dart';
import 'package:spin_flow/model/dao/i_dao_artista_banda.dart';
import 'package:spin_flow/model/dao/i_dao_bike.dart';
import 'package:spin_flow/model/dao/i_dao_categoria_musica.dart';
import 'package:spin_flow/model/dao/i_dao_checkin.dart';
import 'package:spin_flow/model/dao/i_dao_fila_espera_checkin.dart';
import 'package:spin_flow/model/dao/i_dao_grupo_alunos.dart';
import 'package:spin_flow/model/dao/i_dao_manutencao.dart';
import 'package:spin_flow/model/dao/i_dao_mix.dart';
import 'package:spin_flow/model/dao/i_dao_musica.dart';
import 'package:spin_flow/model/dao/i_dao_posicao_bike.dart';
import 'package:spin_flow/model/dao/i_dao_sala.dart';
import 'package:spin_flow/model/dao/i_dao_tipo_manutencao.dart';
import 'package:spin_flow/model/dao/i_dao_turma.dart';
import 'package:spin_flow/model/dao/i_dao_usuario.dart';
import 'package:spin_flow/model/dao/i_dao_video_aula.dart';
import 'package:spin_flow/model/dao/sqlite/dao_aluno_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_artista_banda_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_bike_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_categoria_musica_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_checkin_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_fila_espera_checkin_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_grupo_alunos_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_manutencao_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_mix_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_musica_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_posicao_bike_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_sala_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_tipo_manutencao_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_turma_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_usuario_sqlite.dart';
import 'package:spin_flow/model/dao/sqlite/dao_video_aula_sqlite.dart';
import 'package:spin_flow/model/servico/servico_artista_banda.dart';
import 'package:spin_flow/model/servico/servico_autenticacao.dart';
import 'package:spin_flow/model/servico/servico_checkin_aluno.dart';
import 'package:spin_flow/model/servico/servico_grupo_alunos.dart';
import 'package:spin_flow/model/servico/servico_manutencao.dart';
import 'package:spin_flow/model/servico/servico_mix.dart';
import 'package:spin_flow/model/servico/servico_musica.dart';
import 'package:spin_flow/model/servico/servico_operacao_aula.dart';
import 'package:spin_flow/model/servico/servico_recuperacao_senha.dart';
import 'package:spin_flow/model/servico/servico_sala.dart';
import 'package:spin_flow/model/servico/servico_turma.dart';

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

  // Servicos
  getIt.registerLazySingleton<ServicoAutenticacao>(
    () => ServicoAutenticacao(daoUsuario: getIt<IDAOUsuario>()),
  );
  getIt.registerLazySingleton<ServicoRecuperacaoSenha>(
    () => ServicoRecuperacaoSenha(daoUsuario: getIt<IDAOUsuario>()),
  );
  getIt.registerLazySingleton<ServicoSala>(
    () => ServicoSala(daoSala: getIt<IDAOSala>()),
  );
  getIt.registerLazySingleton<ServicoManutencao>(
    () => ServicoManutencao(
      daoManutencao: getIt<IDAOManutencao>(),
      daoBike: getIt<IDAOBike>(),
      daoTipoManutencao: getIt<IDAOTipoManutencao>(),
    ),
  );
  getIt.registerLazySingleton<ServicoTurma>(
    () =>
        ServicoTurma(daoTurma: getIt<IDAOTurma>(), daoSala: getIt<IDAOSala>()),
  );
  getIt.registerLazySingleton<ServicoGrupoAlunos>(
    () => ServicoGrupoAlunos(
      daoGrupoAlunos: getIt<IDAOGrupoAlunos>(),
      daoAluno: getIt<IDAOAluno>(),
    ),
  );
  getIt.registerLazySingleton<ServicoArtistaBanda>(
    () => ServicoArtistaBanda(dao: getIt<IDAOArtistaBanda>()),
  );
  getIt.registerLazySingleton<ServicoMusica>(
    () => ServicoMusica(
      daoMusica: getIt<IDAOMusica>(),
      daoCategoria: getIt<IDAOCategoriaMusica>(),
      daoVideo: getIt<IDAOVideoAula>(),
    ),
  );
  getIt.registerLazySingleton<ServicoMix>(
    () => ServicoMix(daoMix: getIt<IDAOMix>(), daoMusica: getIt<IDAOMusica>()),
  );
  getIt.registerLazySingleton<ServicoOperacaoAula>(
    () => ServicoOperacaoAula(
      daoTurma: getIt<IDAOTurma>(),
      daoSala: getIt<IDAOSala>(),
      daoPosicaoBike: getIt<IDAOPosicaoBike>(),
      daoCheckin: getIt<IDAOCheckin>(),
      daoManutencao: getIt<IDAOManutencao>(),
      daoTipoManutencao: getIt<IDAOTipoManutencao>(),
    ),
  );
  getIt.registerLazySingleton<ServicoCheckinAluno>(
    () => ServicoCheckinAluno(
      daoTurma: getIt<IDAOTurma>(),
      daoSala: getIt<IDAOSala>(),
      daoAluno: getIt<IDAOAluno>(),
      daoCheckin: getIt<IDAOCheckin>(),
      daoPosicaoBike: getIt<IDAOPosicaoBike>(),
      daoManutencao: getIt<IDAOManutencao>(),
      daoFila: getIt<IDAOFilaEsperaCheckin>(),
    ),
  );

  // Controllers
  getIt.registerFactory<ControladorLogin>(
    () => ControladorLogin(servicoAutenticacao: getIt<ServicoAutenticacao>()),
  );
  getIt.registerFactory<ControladorRecuperacaoSenha>(
    () =>
        ControladorRecuperacaoSenha(servico: getIt<ServicoRecuperacaoSenha>()),
  );
  getIt.registerFactory<ControladorSala>(
    () => ControladorSala(servico: getIt<ServicoSala>()),
  );
  getIt.registerFactory<ControladorManutencao>(
    () => ControladorManutencao(servico: getIt<ServicoManutencao>()),
  );
  getIt.registerFactory<ControladorTurma>(
    () => ControladorTurma(servico: getIt<ServicoTurma>()),
  );
  getIt.registerFactory<ControladorGrupoAlunos>(
    () => ControladorGrupoAlunos(servico: getIt<ServicoGrupoAlunos>()),
  );
  getIt.registerFactory<ControladorArtistaBanda>(
    () => ControladorArtistaBanda(servico: getIt<ServicoArtistaBanda>()),
  );
  getIt.registerFactory<ControladorMusica>(
    () => ControladorMusica(
      servico: getIt<ServicoMusica>(),
      servicoArtista: getIt<ServicoArtistaBanda>(),
    ),
  );
  getIt.registerFactory<ControladorMix>(
    () => ControladorMix(servico: getIt<ServicoMix>()),
  );
  getIt.registerFactory<ControladorOperacaoAula>(
    () => ControladorOperacaoAula(servico: getIt<ServicoOperacaoAula>()),
  );
  getIt.registerFactory<ControladorCheckinAluno>(
    () => ControladorCheckinAluno(servico: getIt<ServicoCheckinAluno>()),
  );
}
