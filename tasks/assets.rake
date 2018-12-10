namespace :assets do
  desc 'Compile assets'
  task :compile do
    cd 'public' do
      Pathname.glob(Pathname.pwd.join('coffee/*.coffee')).each do |coffee_path|
        file_name = coffee_path.basename('.coffee')
        js_path              = Pathname.pwd.join('js', "#{file_name}.js")
        js_min_path          = Pathname.pwd.join('js', "#{file_name}.min.js")

        relative_coffee_path = coffee_path.relative_path_from(Pathname.pwd).to_s
        relative_js_path     = js_path.relative_path_from(Pathname.pwd).to_s
        relative_js_min_path = js_min_path.relative_path_from(Pathname.pwd).to_s

        sh 'coffeebar', '-so',  relative_js_path, relative_coffee_path
        sh 'coffeebar', '-mso', relative_js_min_path, relative_coffee_path # Minified
      end
    end
  end

  desc 'Compile and watch assets'
  task watch: :compile do
    require 'listen'

    def target_file_path(source_file_path)
      source_file_path = Pathname.new(source_file_path)
      public_dir       = source_file_path.dirname.dirname
      target_file_name = "#{source_file_path.basename('.coffee')}.js"
      public_dir.join('js', target_file_name)
    end

    listener = Listen.to('public/coffee') do |modified, added, removed|
      (modified + added).each do |source_file_path|
        target_file_path = target_file_path(source_file_path)
        sh "coffeebar -so #{target_file_path} #{source_file_path}"
      end

      removed.each do |source_file_path|
        target_file_path = target_file_path(source_file_path)
        rm target_file_path
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
