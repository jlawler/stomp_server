module Popable
  def popwhile dest
    frame = self.dequeue dest
    while frame && yield(frame) 
      frame = self.dequeue dest
    end
    self.requeue(dest, frame) if frame
    self
  end
end
