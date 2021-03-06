require('pg')

class Property
  attr_accessor :number_of_bedrooms, :year_built, :buy_let, :build
  attr_reader :id
  def initialize(houses)
    @number_of_bedrooms = houses["number_of_bedrooms"].to_i
    @year_built = houses["year_built"].to_i
    @buy_let = houses["buy_let"]
    @build = houses["build"]
    @id = houses["id"].to_i if houses['id']
  end

  def save()
    #connect pg to the postgres database name from where it is
    db = PG.connect({dbname: 'properties', host:'localhost'})
    #create a variable that will contain the sql command we want to run
    command = "INSERT INTO properties
              (numbers_of_bedrooms, year_built, buy_let, build)
               VALUES
               ($1,$2,$3,$4)
               RETURNING * "
    #we assign each of the values to the $ to avoid external sql injection
    values = [@number_of_bedrooms, @year_built, @buy_let, @build]
    #we associate a string to the command we want to run
    db.prepare("save", command)
    #take the first element of the date (id) and saves it into the instance variable
    @id = db.exec_prepared("save", values)[0]["id"].to_i
    #close the connection
    db.close()
  end


  def update()
    db = PG.connect({dbname: 'properties', host:'localhost'})
    command = "UPDATE properties
              SET (numbers_of_bedrooms, year_built, buy_let, build)
              =
              ($1,$2,$3,$4)
              WHERE id = $5"
    values = [@number_of_bedrooms, @year_built, @buy_let, @build, @id]
    db.prepare("update", command)
    db.exec_prepared("update", values)
    db.close()
  end


  def delete()
    db = PG.connect({dbname: 'properties', host:'localhost'})
    command = "DELETE FROM properties WHERE id = $1"
    value = [@id]
    db.prepare("delete_one", command)
    db.exec_prepared("delete_one", value)
    db.close
  end

  def Property.find(id)
    db = PG.connect({dbname: 'properties', host:'localhost'})
    command = "SELECT FROM properties WHERE id = $1"
    value = [id]
    db.prepare("find_one", command)
    house_found = db.exec_prepared("find_one", value)
    db.close
    property =house_found[0]
    return Property.new(property)

  end
  # def find()
  #   db = PG.connect({dbname: 'properties', host:'localhost'})
  #   command = "SELECT * FROM properties WHERE id = $1"
  #   value = [@id]
  #   db.prepare("find_one", command)
  #   db.exec_prepared("find_one", value)
  #   db.close
  # end

  def Property.find_by_year(year)
    db = PG.connect({dbname: 'properties', host:'localhost'})
    command = "SELECT FROM properties WHERE $1"
    value = [year]
    db.prepare("find_by_year", command)
    houses_by_year = db.exec_prepared("find_by_year", value)
    db.close
    property =houses_by_year[0]
    return Property.new(property)
  end
end
