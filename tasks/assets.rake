namespace :assets do
  desc 'Compile assets'
  task :compile do
    public_dir = Pathname.pwd.join('public')

    Pathname.glob(public_dir.join('coffee/*.coffee')).each do |coffee_path|
      file_name   = coffee_path.basename('.coffee')
      js_path     = public_dir.join('js', "#{file_name}.js")
      js_min_path = public_dir.join('js', "#{file_name}.min.js")

      relative_coffee_path = coffee_path.relative_path_from(Pathname.pwd).to_s
      relative_js_path     = js_path.relative_path_from(Pathname.pwd).to_s
      relative_js_min_path = js_min_path.relative_path_from(Pathname.pwd).to_s

      sh 'coffeebar', '-so',  relative_js_path, relative_coffee_path
      sh 'coffeebar', '-mso', relative_js_min_path, relative_coffee_path # Minified
    end
  end

  desc 'Compile and watch assets'
  task watch: :compile do
    require 'listen'

    public_dir = Pathname.pwd.join('public')

    listener = Listen.to('public/coffee') do |modified, added, removed|
      (modified + added).each do |source_file_path|
        coffee_path = Pathname.new(source_file_path)
        file_name   = coffee_path.basename('.coffee')
        js_path     = public_dir.join('js', "#{file_name}.js")
        js_min_path = public_dir.join('js', "#{file_name}.min.js")

        relative_coffee_path = coffee_path.relative_path_from(Pathname.pwd).to_s
        relative_js_path     = js_path.relative_path_from(Pathname.pwd).to_s
        relative_js_min_path = js_min_path.relative_path_from(Pathname.pwd).to_s

        sh 'coffeebar', '-so',  relative_js_path, relative_coffee_path
        sh 'coffeebar', '-mso', relative_js_min_path, relative_coffee_path # Minified
      end

      removed.each do |source_file_path|
        coffee_path = Pathname.new(source_file_path)
        file_name   = coffee_path.basename('.coffee')
        js_path     = public_dir.join('js', "#{file_name}.js")
        js_min_path = public_dir.join('js', "#{file_name}.min.js")

        relative_js_path     = js_path.relative_path_from(Pathname.pwd).to_s
        relative_js_min_path = js_min_path.relative_path_from(Pathname.pwd).to_s

        rm relative_js_path
        rm relative_js_min_path
      end
    end

    puts 'Listening for changes.'
    listener.start

    trap('INT') do
      puts
      puts "Alright, I'm done here."
      exit
    end

    sleep
  end
end
