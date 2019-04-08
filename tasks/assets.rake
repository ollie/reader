namespace :assets do
  desc 'Compile assets'
  task :compile do
    public_dir = Pathname.pwd.join('public')
    sh 'coffee', '--compile', '--output', public_dir.join('js').to_s, public_dir.join('coffee').to_s
  end

  desc 'Compile and watch assets'
  task watch: :compile do
    public_dir = Pathname.pwd.join('public')
    sh 'coffee', '--compile', '--watch', '--output', public_dir.join('js').to_s, public_dir.join('coffee').to_s
  end
end
