#ifndef __vtkChickenCommand_h
#define __vtkChickenCommand_h

#include "vtkCommand.h"

extern "C" void 
execute_vtk_chicken_command (void *, C_word, void *, unsigned long, void *);

class vtkChickenCommand : public vtkCommand {
public:
  virtual void Execute (vtkObject *caller, unsigned long eventId, 
                        void *callData) {
    execute_vtk_chicken_command (this, continuation, caller, 
				 eventId, callData);
  }

  static vtkChickenCommand * New(C_word continuation) {
    return new vtkChickenCommand (continuation);
  }

protected:
  C_word continuation;

  vtkChickenCommand (C_word continuation_) : continuation (continuation_) 
  { }
};

#endif
