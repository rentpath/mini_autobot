#This is utility class. It has methods that serve as Rent utility

class Util

  def create_random_email
    email_address= "TEST"+Array.new(8){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join + "@qarent.com"
    return email_address
  end

  def create_random_password
    password= "TEST"+Array.new(5){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
    return password
  end

end

