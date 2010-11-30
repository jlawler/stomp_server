
module StompServer
class DBMQueue < Queue

  def initialize *args
    super
    # Please don't use dbm files for storing large frames, it's problematic at best and uses large amounts of memory.
    # sdbm croaks on marshalled data that contains certain characters, so we don't use it at all
    @dbm = false
    if RUBY_PLATFORM =~/linux|bsd/
      types = ['bdb','dbm','gdbm']
    else
      types = ['bdb','gdbm']
    end
    types.each do |dbtype|
      begin
        require dbtype
        @dbm = dbtype
        puts "#{@dbm} loaded"
        break
      rescue LoadError => e
      end
    end
    raise "No DBM library found. Tried bdb,dbm,gdbm" unless @dbm
    @db = Hash.new
    @queues.keys.each {|q| _open_queue(q)}
  end

  def dbmopen(dbname)
    case @dbm
    when 'bdb'
      BDB::Hash.new(dbname, nil, "a")
    when 'dbm'
      DBM.open(dbname)
    when 'gdbm'
      GDBM.open(dbname)
    end
  end


  def _open_queue(dest)
    queue_name = dest.gsub('/', '_')
    dbname = @directory + '/' + queue_name
    @db[dest] = Hash.new
    @db[dest][:dbh] = dbmopen(dbname)
    @db[dest][:dbname] = dbname
  end


  def _close_queue(dest)
    @db[dest][:dbh].close
    dbname = @db[dest][:dbname]
    [ '', '.db',  '.pag',  '.dir'  ].each do |ext|
      filename = dbname + ext
      File.delete(filename) if File.exists?(filename) 
    end
  end

  def _writeframe(dest,frame,msgid)
    @db[dest][:dbh][msgid] = Marshal::dump(frame)
  end

  def _readframe(dest,msgid)
    frame_image = @db[dest][:dbh][msgid]
    Marshal::load(frame_image)
  end

end
end
