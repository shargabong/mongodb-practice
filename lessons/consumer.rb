require 'bunny'
require 'json'

puts "Запуск воркера"

connection = Bunny.new(hostname: 'localhost')
connection.start

channel = connection.create_channel
queue = channel.queue('dev_logs', durable: true)

puts "Ожидание логов в очереди 'dev_logs'. Для выхода нажмите CTRL+C"

begin
  queue.subscribe(block: true) do |delivery_info, _properties, body|
    log_data = JSON.parse(body)

    if log_data['level'] == 'error'
      puts "   [ALERT] Обнаружена ошибка в системе!"
      puts "   Время: #{log_data['timestamp']}"
      puts "   Компонент: #{log_data['component']}"
      puts "   Сообщение: #{log_data['message']}"
      puts "-" * 40
    end
  end
rescue Interrupt => _
  channel.close
  connection.close
  puts "\n ВОРКЕР ОСТАНОВЛЕН."
end