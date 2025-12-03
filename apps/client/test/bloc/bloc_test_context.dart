/// Utility for setting up and managing Bloc test dependencies.
///
/// Intended for use with [blocTest] and [blocPresentationTest].
/// [BlocTestContext] provides a structured way to initialize a Bloc and its repository.
/// It's used to simplify the test setup for more complex Bloc test scenarios.
///
/// Type parameters:
/// - [TUser]: The user type used for context (e.g. a [User]).
/// - [TBlocBuilder]: The builder type that creates the Bloc and repository.
/// - [TBloc]: The Bloc type under test.
/// - [TRepo]: The repository type used by the Bloc.
class BlocTestContext<TUser, TBlocBuilder, TBloc, TRepo> {
  late TBlocBuilder builder;
  late TBloc bloc;
  late TRepo repo;

  final TBlocBuilder Function(TUser currentUser) blocBuilder;
  final TBloc Function(TBlocBuilder builder) getBloc;
  final TRepo Function(TBlocBuilder builder) getRepo;

  /// Creates a [BlocTestContext] with the required dependency builders.
  ///
  /// - [blocBuilder]: Builds the bloc and dependencies for the current user.
  /// - [getBloc]: Retrieves the Bloc from the builder.
  /// - [getRepo]: Retrieves the repository from the builder.
  BlocTestContext({required this.blocBuilder, required this.getBloc, required this.getRepo});

  /// Initializes the builder, Bloc, and repository for the given [currentUser].
  ///
  /// Call this in your test setup to prepare all dependencies for the Bloc under test.
  void setup(TUser currentUser) {
    builder = blocBuilder(currentUser);
    bloc = getBloc(builder);
    repo = getRepo(builder);
  }
}
