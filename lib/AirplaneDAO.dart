import 'package:floor/floor.dart';
import 'Airplane.dart';

@dao
abstract class AirplaneDAO {

  @insert
  Future<void> insertAirplane(Airplane airplane);

  @update
  Future<void> updateAirplane(Airplane airplane);

  @delete
  Future<int> deleteAirplane(Airplane airplane);



  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> findAllAirplanes(); // This method retrieves all airplanes
}
