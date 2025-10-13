class BlocTestContext<TUser, TFactory, TBloc, TRepo> {
  late TFactory factory;
  late TBloc bloc;
  late TRepo repo;

  final TFactory Function(TUser currentUser) factoryBuilder;
  final TBloc Function(TFactory factory) getBloc;
  final TRepo Function(TFactory factory) getRepo;

  BlocTestContext({
    required this.factoryBuilder,
    required this.getBloc,
    required this.getRepo,
  });

  void setup(TUser currentUser) {
    factory = factoryBuilder(currentUser);
    bloc = getBloc(factory);
    repo = getRepo(factory);
  }
}
