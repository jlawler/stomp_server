module Popable
  def popwhile dest
    frame = self.dequeue dest
    puts "popping #{ frame }"
    while frame && yield(frame) 
      frame = self.dequeue dest
    end
    
    if frame
      self.requeue(dest, frame) 
      puts "requeuing #{ frame }"
    end
    self
  end
end
