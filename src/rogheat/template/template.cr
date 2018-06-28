require "csv"
require "process"

abstract class Template
    abstract def check
    abstract def generate
end

struct Password
  @hsymbol = {true => "-y", false => ""}
  @hcapital = {true => "-c", false => "-A"}
  @hnumeral = {true => "-n", false => "-0"}
  @hambiguous = {true => "-B", false => ""}

  def initialize(@path : String = "/bin/pwgen",
                 @length : Int32 = 12,
                 @symbol : Bool = true,
                 @capital : Bool = true,
                 @numeral : Bool = true,
                 @ambiguous : Bool = true
                )
  end

  def gen : String
    args = Array(String).new
    args << @hsymbol[@symbol]
    args << @hcapital[@capital]
    args << @hnumeral[@numeral]
    args << @hambiguous[@ambiguous]
    args << @length.to_s
    args << 1.to_s

    #args = ["-y", "-c", "-n", "-B", "12", "1"]

    stdout = IO::Memory.new
    status = Process.run @path, args: args, output: stdout, error: STDERR

    if status.success?
      stdout.to_s
    else
      "error"
    end
  end
end
