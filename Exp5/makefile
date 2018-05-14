NAME = cbox
OBJS = $(NAME).obj
RES = $(NAME).res

LINK_FLAG = /subsystem:windows /debug /debugtype:cv
ML_FLAG = /c /coff /Zi

$(NAME).exe: $(OBJS) $(RES)
	Link $(LINK_FLAG) $(OBJS) $(RES)
.asm.obj:
	ml   $(ML_FLAG) $<

.rc.res:
       rc  $<
clean:
	del *.obj
