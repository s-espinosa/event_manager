require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = 'e179a6973728c4dd3fb1204283aaccb5'

def clean_zipcode(zipcode)
  zipcode = zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(phone)
  phone = phone.to_s.gsub(/\D/, "")
  phone = phone[1..10] if phone.length == 11 && phone[0] == "1"
  phone = nil unless phone.length == 10
  phone
end

def registration_time(full_date)
  date_with_time = DateTime.strptime(full_date, "%m/%d/%y %H:%M")
  date_with_time.hour
end

def registration_day(full_date)
  date_with_time = DateTime.strptime(full_date, "%m/%d/%y %H:%M")
  date_with_time.wday
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir('output') unless Dir.exists? 'output'
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized"

contents        = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
template_letter = File.read 'form_letter.erb'
erb_template    = ERB.new template_letter

contents.each do |row|
  id          = row[0]
  name        = row[:first_name]
  zipcode     = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)

  save_thank_you_letters(id, form_letter)
end
