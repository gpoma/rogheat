require "./template"

struct Person
  @@domain = "@vet-alfort.fr"
  @@pwgen = Password.new

  getter password : String | Nil
  getter email : String | Nil
  getter login : String | Nil
  getter firstname : String = ""
  getter lastname : String = ""
  getter ine : String | Nil
  getter civi : String | Nil
  getter dob : String | Nil

  def initialize(input : CSV)
    @firstname = input["CAND_PRENOM"].capitalize
    @lastname = input["CAND_NOM"].upcase
    @ine = input["CAND_BEA"].upcase
    @civi = input["CAND_CIVILITE"]
    @dob = input["CAND_DATE_NAIS"]
    @login = "#{self.strip(@firstname.downcase)}.#{self.strip(@lastname.downcase)}#{@@domain}"
    @email = "#{@login}"
    @password = @@pwgen.gen.chomp
  end

  private def strip(in : String) : String
    in.downcase.tr("àáâãäçèéêëìíîïñòóôõöùúûüýÿ '", "aaaaaceeeeiiiinooooouuuuyy--")
  end
end

struct Output
  getter name : String
  getter directory : String
  getter quote : Char
  getter separator : Char

  def initialize(@name, @directory = ".", @separator = ';', @quote = '"')
  end
end

class Rentree < Template
  @people = [] of Person
  property separator : Char
  property quote : Char

  @headers = {
    "CAND_NUMERO",
    "CAND_BEA",
    "CAND_CIVILITE",
    "CAND_NOM",
    "CAND_PRENOM",
    "CAND_PRENOM2",
    "CAND_DATE_NAIS",
    "CAND_COMNAIS",
    "CAND_COMNAIS_CODE",
    "DPTG_CODE_NAIS",
    "PAYS_CODE_NAIS",
    "NAT_ORDRE",
    "CAND_ADR1_PARENT",
    "CAND_ADR2_PARENT",
    "CAND_CO_PARENT",
    "CAND_VILLE_PARENT",
    "CAND_VILLE_PARENT_CODE",
    "CAND_PAYS_PARENT",
    "CAND_TEL_PARENT",
    "CAND_PORT_SCOL",
    "CAND_EMAIL_SCOL",
    "BAC_CODE",
    "CAND_ANBAC",
    "ETAB_CODE_BAC",
    "ETAB_LIBELLE_BAC",
    "CAND_VILLE_BAC",
    "DPTG_ETAB_BAC",
    "PAYS_ETAB_BAC",
    "HIST_ENS_DER_ETAB",
    "ETAB_CODE_DER_ETAB",
    "HIST_LIBELLE_DER_ETAB",
    "HIST_VILLE_DER_ETAB",
    "DPTG_CODE_DER_ETAB",
    "PAYS_CODE_DER_ETAB",
    "CAND_ETAB_CHOIX",
    "CAND_DATE_NAIS_PROVISOIRE",
    "CAND_NOM_USUEL",
    "CAND_PRENOM3",
    "CAND_ADR3_PARENT",
    "ANNEE_PREM_ETAB",
    "CAND_ENFANTS_CHARGE",
    "PRO_CODE_1",
    "PRO_CODE_2"
  }

  def initialize(in : IO, @separator : Char = CSV::DEFAULT_SEPARATOR, @quote : Char = CSV::DEFAULT_QUOTE_CHAR)
    @input_file = CSV.new(in, true, true, @separator, @quote)
    @pwgen = Password.new
  end

  def check
    puts "Checking file's headers..."
    input_headers = @input_file.headers
    if input_headers == @headers.to_a
      puts "OK"
    else
      puts "Uho"
      puts "Missing headers : #{@headers.to_a-input_headers}"
      exit 2
    end
  end

  def generate
    self.build
    self.oracle
    self.active_directory
    self.moodle
    self.password
  end

  def build
      while @input_file.next
        @people << Person.new @input_file
      end
  end

  def oracle
    oracle = Output.new name: "IMPORT_POSTBAC.csv", directory: "Oracle", separator: ';'

    if !Dir.exists? oracle.directory
      Dir.mkdir_p oracle.directory
    end

    file = File.new "#{oracle.directory}/#{oracle.name}", "w"

    CSV.build file, oracle.separator, oracle.quote do |csv|
      @people.each do |person|
        # 2018002;2505019101Z;MME;BUSI;Alexia;;07011994;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        csv.row nil, person.ine, person.civi, person.lastname, person.firstname, nil, person.dob, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
      end
    end

    file.close
  end

  def active_directory
    ad = Output.new name: "users-db.csv", directory: "AD", separator: '\\'

    if !Dir.exists? ad.directory
      Dir.mkdir_p ad.directory
    end

    file = File.new "#{ad.directory}/#{ad.name}", "w"

    CSV.build file, ad.separator, ad.quote do |csv|
      csv.row "nom", "givenName", "password", "licence"
      @people.each do |person|
        csv.row person.lastname, person.firstname, person.password, 2
      end
    end

    file.close
  end

  def moodle
    moodle = Output.new name: "Moodle.csv", directory: "Moodle"

    if !Dir.exists? moodle.directory
      Dir.mkdir_p moodle.directory
    end

    file = File.new "#{moodle.directory}/#{moodle.name}", "w"

    CSV.build file, moodle.separator, moodle.quote do |csv|
      # firstname lastname email username password lang deleted cohort1 type1   auth
      csv.row "lastname", "firstname", "email", "username", "password", "deleted", "auth"
      @people.each do |person|
        csv.row person.lastname, person.firstname, person.email, person.login, 123, 0, "ldap"
      end
    end

    file.close
  end

  def password
    pw = Output.new name: "PW.csv", directory: "Moodle"

    if !Dir.exists? pw.directory
      Dir.mkdir_p pw.directory
    end

    file = File.new "#{pw.directory}/#{pw.name}", "w"

    CSV.build file, pw.separator, pw.quote do |csv|
      csv.row "Nom", "Prenom", "Email", "Login", "Mot de passe"
      @people.each do |person|
        csv.row person.lastname, person.firstname, person.email, person.login, person.password
      end
    end

    file.close
  end
end
