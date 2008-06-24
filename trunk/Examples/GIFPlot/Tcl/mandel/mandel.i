// Special module to run the mandlebrot set
%module gifplot
%include gifplot.i

%inline %{

void mandel(Plot2D *p2, int tol) {
	double scalingx;
	double scalingy;
	double zr,zi,ztr,zti,cr,ci;
	double cscale;
	int    i,j,n;
	FrameBuffer *f;

	f = p2->frame;
	scalingx = (p2->xmax-p2->xmin)/f->width;
	scalingy = (p2->ymax-p2->ymin)/f->height;
	
	cscale = 239.0/tol;
	printf("working...\n");
	for (i = 0; i < f->width; i++) {
	  for (j = 0; j < f->height; j++) {
	    zr = scalingx*i + p2->xmin;
	    zi = scalingy*j + p2->ymin;
	    cr = zr;
	    ci = zi;
	    n = 0;
	    while (n < tol) {
	      ztr = zr*zr-zi*zi + cr;
	      zti = 2*zr*zi + ci;
	      zr = ztr;
	      zi = zti;
	      if (ztr*ztr + zti*zti > 20) break;
	      n = n + 1;
	    }
	    
	    if (n >= tol) FrameBuffer_plot(f,i,j,BLACK);
	    else FrameBuffer_plot(f,i,j,16+(int) (n*cscale));
	  }
	  if ((i % 10) == 0) printf("%d\n",i);
	}

}
		
%}
	

