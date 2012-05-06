/* ----------------------------------------------------------------------------- 
 * plot3d.c
 *
 *     Three-dimensional plotting.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 * Copyright (C) 1995-1996
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#define PLOT3D
#include "gifplot.h"
#include <math.h>
#include <float.h>

#define ORTHO        1
#define PERSPECTIVE  2
/* ------------------------------------------------------------------------
   Plot3D *new_Plot3D(FrameBuffer *f, double xmin, double ymin, double zmin,
   double xmax, double ymax, double zmax)

   Creates a new 3D plot.  Min and max coordinates are primarily used to
   pick some default parameters.  Returns NULL on failure
   ------------------------------------------------------------------------- */

Plot3D *new_Plot3D(FrameBuffer *f, double xmin, double ymin, double zmin,
		   double xmax, double ymax, double zmax) {

  Plot3D  *p3;
  void Plot3D_maketransform(Plot3D *p3);
  
  /* Check to make sure the framebuffer and min/max parameters are valid */

  if (!f) return (Plot3D *) 0;
  if ((xmin > xmax) || (ymin > ymax) || (zmin > zmax)) return (Plot3D *) 0;

  p3 = (Plot3D *) malloc(sizeof(Plot3D));
  p3->frame = f;
  p3->xmin = xmin;
  p3->ymin = ymin;
  p3->zmin = zmin;
  p3->xmax = xmax;
  p3->ymax = ymax;
  p3->zmax = zmax;

  /* Set view region to the entire size of the framebuffer */

  p3->view_xmin = 0;
  p3->view_ymin = 0;
  p3->view_xmax = f->width;
  p3->view_ymax = f->height;
  p3->width = f->width;
  p3->height = f->height;
  
  /* Calculate a center point based off the min and max coordinates given */

  p3->xcenter = (xmax - xmin)/2.0 + xmin;
  p3->ycenter = (ymax - ymin)/2.0 + ymin;
  p3->zcenter = (zmax - zmin)/2.0 + zmin;

  /* Calculate the aspect ratio of the viewing region */

  p3->aspect = (double) f->width/(double) f->height;

  /* Set default view parameters */
  p3->xshift = 1.0;
  p3->yshift = 1.0;
  p3->zoom   = 0.5;
  p3->fovy   = 40.0;         /* 40 degree field of view */

  /* Create matrices */

  p3->model_mat = new_Matrix();
  p3->view_mat = new_Matrix();
  p3->center_mat = new_Matrix();
  p3->fullmodel_mat = new_Matrix();
  p3->trans_mat = new_Matrix();
  p3->pers_mode = ORTHO;

  FrameBuffer_zresize(p3->frame,p3->width, p3->height);
  Matrix_identity(p3->view_mat);
  Matrix_identity(p3->model_mat);
  Matrix_translate(p3->center_mat, -p3->xcenter,-p3->ycenter,-p3->zcenter);
  Plot3D_maketransform(p3);
  return p3;
}

/* ---------------------------------------------------------------------
   delete_Plot3D(Plot3D *p3)

   Deletes a 3D plot
   --------------------------------------------------------------------- */

void delete_Plot3D(Plot3D *p3) {
  if (p3) {
    delete_Matrix(p3->view_mat);
    delete_Matrix(p3->model_mat);
    delete_Matrix(p3->trans_mat);
    free((char *) p3);
  }
}

/* ---------------------------------------------------------------------
   Plot3D *Plot3D_copy(Plot3D *p3)

   This makes a copy of the 3D plot structure and returns a pointer to it.
   --------------------------------------------------------------------- */

Plot3D *Plot3D_copy(Plot3D *p3) {
  Plot3D *c3;
  if (p3) {
    c3 = (Plot3D *) malloc(sizeof(Plot3D));
    if (c3) {
      c3->frame = p3->frame;
      c3->view_xmin = p3->view_xmin;
      c3->view_ymin = p3->view_ymin;
      c3->view_xmax = p3->view_xmax;
      c3->view_ymax = p3->view_ymax;
      c3->xmin = p3->xmin;
      c3->ymin = p3->ymin;
      c3->zmin = p3->zmin;
      c3->xmax = p3->xmax;
      c3->ymax = p3->ymax;
      c3->zmax = p3->zmax;
      c3->xcenter = p3->xcenter;
      c3->ycenter = p3->ycenter;
      c3->zcenter = p3->zcenter;
      c3->fovy = p3->fovy;
      c3->aspect = p3->aspect;
      c3->znear = p3->znear;
      c3->zfar = p3->zfar;
      c3->center_mat = Matrix_copy(p3->center_mat);
      c3->model_mat = Matrix_copy(p3->model_mat);
      c3->view_mat = Matrix_copy(p3->view_mat);
      c3->fullmodel_mat = Matrix_copy(p3->fullmodel_mat);
      c3->trans_mat = Matrix_copy(p3->trans_mat);
      c3->lookatz = p3->lookatz;
      c3->xshift = p3->xshift;
      c3->yshift = p3->yshift;
      c3->zoom = p3->zoom;
      c3->width = p3->width;
      c3->height = p3->height;
      c3->pers_mode = p3->pers_mode;
    }
    return c3;
  } else {
    return (Plot3D *) 0;
  }
}

/* ----------------------------------------------------------------------
   Plot3D_clear(Plot3D *p3, Pixel bgcolor)

   Clear the pixel and zbuffer only for the view region of this image.
   ---------------------------------------------------------------------- */
void
Plot3D_clear(Plot3D *p3, Pixel bgcolor) {
  int i,j;

  for (i = p3->view_xmin; i < p3->view_xmax; i++)
    for (j = p3->view_ymin; j < p3->view_ymax; j++) {
      p3->frame->pixels[j][i] = bgcolor;
      p3->frame->zbuffer[j][i] = ZMIN;
    }
}

/* ---------------------------------------------------------------------
   Plot3D_maketransform(Plot3D *p3)

   This function builds the total 3D transformation matrix from a
   collection of components.

   Trans = View * Rotation * Center

   Where View is the viewing transformation matrix, Rotation is the
   model rotation matrix, Center is the translation matrix used to
   center the Model at the origin.
   --------------------------------------------------------------------- */

void
Plot3D_maketransform(Plot3D *p3) {

  Matrix_multiply(p3->model_mat,p3->center_mat, p3->fullmodel_mat);
  Matrix_multiply(p3->view_mat,p3->fullmodel_mat, p3->trans_mat);
}
   
/* ---------------------------------------------------------------------
   Plot3D_perspective(Plot3D *p3, double fovy, double znear, double zfar)

   Sets up the perspective viewing transformation.   Assumes "lookat"
   has already been called.
   --------------------------------------------------------------------- */

void
Plot3D_perspective(Plot3D *p3, double fovy, double znear, double zfar) {
  double theta;
  double mat[16];

  p3->fovy = fovy;
  p3->znear = znear;
  p3->zfar = zfar;

  theta = 3.1415926*fovy/180.0;

  Matrix_identity(mat);
  mat[0] = cos(theta/2.0)/(sin(theta/2.0)*p3->aspect);
  mat[5] = cos(theta/2.0)/(sin(theta/2.0));
  mat[10] = -(zfar + znear)/(zfar-znear);
  mat[14] = -1.0;
  mat[11] = -(2*zfar*znear)/(zfar - znear);
  mat[15] = 0.0;

  /* Update the view transformation matrix */
  
  Matrix_multiply(mat,p3->view_mat,p3->view_mat);

  /* Update the global transformation matrix */
  
  Plot3D_maketransform(p3);
  p3->pers_mode = PERSPECTIVE;

}

/* ---------------------------------------------------------------------
   Plot3D_lookat(Plot3D *p3, double z)

   A greatly simplified version of (lookat).  Specifies the position
   of the viewpoint. (can be used for moving image in or out).

   Destroys the current viewing transformation matrix, so it will have
   to be recalculated.
   --------------------------------------------------------------------- */
  
void
Plot3D_lookat(Plot3D *p3, double z) {
  if (p3) {
    Matrix_translate(p3->view_mat, 0,0,-z);
    p3->lookatz = z;
    Plot3D_maketransform(p3);
  }
}

/* -------------------------------------------------------------------------
   Plot3D_autoperspective(Plot3D *p3, double fovy)

   Automatically figures out a semi-decent viewpoint given the
   min,max parameters currently set for this image
   ------------------------------------------------------------------------- */

void
Plot3D_autoperspective(Plot3D *p3, double fovy) {

  /* Make a perspective transformation matrix for this system */

  double  zfar;
  double  znear;
  double  d, dmax;
  double  cx,cy,cz;
  double  xmin,xmax,ymin,ymax,zmin,zmax;

  xmin = p3->xmin;
  ymin = p3->ymin;
  zmin = p3->zmin;
  xmax = p3->xmax;
  ymax = p3->ymax;
  zmax = p3->zmax;
  cx = p3->xcenter;
  cy = p3->ycenter;
  cz = p3->zcenter;
  
  /* Calculate longest point from center point */

  dmax = (xmin-cx)*(xmin-cx) + (ymin-cy)*(ymin-cy) + (zmin-cz)*(zmin-cz);
  d = (xmax-cx)*(xmax-cx) + (ymin-cy)*(ymin-cy) + (zmin-cz)*(zmin-cz);
  if (d > dmax) dmax = d;
  d = (xmin-cx)*(xmin-cx) + (ymax-cy)*(ymax-cy) + (zmin-cz)*(zmin-cz);
  if (d > dmax) dmax = d;
  d = (xmax-cx)*(xmax-cx) + (ymax-cy)*(ymax-cy) + (zmin-cz)*(zmin-cz);
  if (d > dmax) dmax = d;
  d = (xmin-cx)*(xmin-cx) + (ymin-cy)*(ymin-cy) + (zmax-cz)*(zmax-cz);
  if (d > dmax) dmax = d;
  d = (xmax-cx)*(xmax-cx) + (ymin-cy)*(ymin-cy) + (zmax-cz)*(zmax-cz);
  if (d > dmax) dmax = d;
  d = (xmin-cx)*(xmin-cx) + (ymax-cy)*(ymax-cy) + (zmax-cz)*(zmax-cz);
  if (d > dmax) dmax = d;
  d = (xmax-cx)*(xmax-cx) + (ymax-cy)*(ymax-cy) + (zmax-cz)*(zmax-cz);
  if (d > dmax) dmax = d;

  dmax = sqrt(dmax);
  d = p3->lookatz;
  
  znear = d - dmax;
  zfar = znear+1.5*dmax;
  Plot3D_perspective(p3, fovy,znear,zfar);
  
}

   
/* ---------------------------------------------------------------------
   Plot3D_ortho(Plot3D *p3, double left, double right, double bottom, double top)

   Sets up an orthographic viewing transformation.   
   --------------------------------------------------------------------- */

void
Plot3D_ortho(Plot3D *p3, double left, double right, double bottom, double top) {


  Matrix_identity(p3->view_mat);
  p3->view_mat[0] = (2.0/(right - left))/p3->aspect;
  p3->view_mat[5] = 2.0/(top - bottom);
  p3->view_mat[10] = -1;
  p3->view_mat[15] = 1.0;
  p3->view_mat[3] = -(right+left)/(right-left);
  p3->view_mat[7] = -(top+bottom)/(top-bottom);

  /* Update the global transformation matrix */
  
  Plot3D_maketransform(p3);
  p3->pers_mode = ORTHO;
  p3->ortho_left = left;
  p3->ortho_right = right;
  p3->ortho_bottom = bottom;
  p3->ortho_top = top;

}

/* ---------------------------------------------------------------------
   Plot3D_autoortho(Plot3D *p3)

   Automatically pick an orthographic projection that's probably
   pretty good.
   --------------------------------------------------------------------- */

void
Plot3D_autoortho(Plot3D *p3) {

  /* Make a perspective transformation matrix for this system */

  double  d, dmax;
  double  cx,cy,cz;
  double  xmin,xmax,ymin,ymax,zmin,zmax;

  xmin = p3->xmin;
  ymin = p3->ymin;
  zmin = p3->zmin;
  xmax = p3->xmax;
  ymax = p3->ymax;
  zmax = p3->zmax;
  cx = p3->xcenter;
  cy = p3->ycenter;
  cz = p3->zcenter;
  
  /* Calculate longest point from center point */

  dmax = (xmin-cx)*(xmin-cx) + (ymin-cy)*(ymin-cy) + (zmin-cz)*(zmin-cz);
  d = (xmax-cx)*(xmax-cx) + (ymin-cy)*(ymin-cy) + (zmin-cz)*(zmin-cz);
  if (d > dmax) dmax = d;
  d = (xmin-cx)*(xmin-cx) + (ymax-cy)*(ymax-cy) + (zmin-cz)*(zmin-cz);
  if (d > dmax) dmax = d;
  d = (xmax-cx)*(xmax-cx) + (ymax-cy)*(ymax-cy) + (zmin-cz)*(zmin-cz);
  if (d > dmax) dmax = d;
  d = (xmin-cx)*(xmin-cx) + (ymin-cy)*(ymin-cy) + (zmax-cz)*(zmax-cz);
  if (d > dmax) dmax = d;
  d = (xmax-cx)*(xmax-cx) + (ymin-cy)*(ymin-cy) + (zmax-cz)*(zmax-cz);
  if (d > dmax) dmax = d;
  d = (xmin-cx)*(xmin-cx) + (ymax-cy)*(ymax-cy) + (zmax-cz)*(zmax-cz);
  if (d > dmax) dmax = d;
  d = (xmax-cx)*(xmax-cx) + (ymax-cy)*(ymax-cy) + (zmax-cz)*(zmax-cz);
  if (d > dmax) dmax = d;

  dmax = sqrt(dmax);

  Plot3D_ortho(p3,-dmax,dmax,-dmax,dmax);
  
}



/* -------------------------------------------------------------------------
   Plot3D_setview(Plot3D *p3, int vxmin, int vymin, int vxmax, int vymax)

   Sets the viewport for this 3D graph.  Will recalculate all of the
   local viewing transformation matrices accordingly.
   ------------------------------------------------------------------------- */
void
Plot3D_setview(Plot3D *p3, int vxmin, int vymin, int vxmax, int vymax) {
  if (p3) {
    if ((vxmin > vxmax) || (vymin >vymax)) return;
    p3->view_xmin = vxmin;
    p3->view_ymin = vymin;
    p3->view_xmax = vxmax;
    p3->view_ymax = vymax;
    p3->width = (vxmax - vxmin);
    p3->height = (vymax - vymin);
    p3->aspect = (double) p3->width/(double) p3->height;

    /* Fix up the viewing transformation matrix */

    if (p3->pers_mode == PERSPECTIVE) {
      Plot3D_lookat(p3,p3->lookatz);
      Plot3D_perspective(p3,p3->fovy,p3->znear,p3->zfar);
    } else {
      Plot3D_ortho(p3,p3->ortho_left,p3->ortho_right,p3->ortho_bottom, p3->ortho_top);
    }
    FrameBuffer_setclip(p3->frame,vxmin,vymin,vxmax,vymax);
  }
}

/* ---------------------------------------------------------------------------
   Plot2D_start(Plot2D *p3)

   Set up viewing region and other parameters for this image.
   --------------------------------------------------------------------------- */

void
Plot3D_start(Plot3D *p3) {
  if (p3)
    FrameBuffer_setclip(p3->frame, p3->view_xmin,p3->view_ymin,p3->view_xmax, p3->view_ymax);

}

/* -------------------------------------------------------------------------
   Plot3D_plot(Plot3D *p3, double x, double y, double z, Pixel Color)

   Plot a 3D point
   ------------------------------------------------------------------------- */
   
void
Plot3D_plot(Plot3D *p3, double x, double y, double z, Pixel color) { 

  GL_Vector t;
  int      ix, iy;
  double   invw;
  FrameBuffer *f;
  
  /* Perform a transformation */

  Matrix_transform4(p3->trans_mat,x,y,z,1,&t);

  /* Scale the coordinates into unit cube */
  
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
#ifdef GL_DEBUG
  fprintf(stdout,"t.x = %g,   t.y = %g,    t.z = %g\n", t.x,t.y,t.z);
#endif
  /* Calculate the x and y coordinates */

  ix = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5); 
  iy = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5); 

  if ((ix >= 0) && (ix < p3->width) &&
      (iy >= 0) && (ix < p3->height)) {
    ix += p3->view_xmin;
    iy += p3->view_ymin;
    f = p3->frame;
    if (t.z <= f->zbuffer[iy][ix]) {
      f->pixels[iy][ix] = color;
      f->zbuffer[iy][ix] = t.z;
    }
  }
}

/* ----------------------------------------------------------------------
   Plot3D_rotx(Plot3D *p3, double deg)

   Rotate the model around its x axis.
   ---------------------------------------------------------------------- */

void
Plot3D_rotx(Plot3D *p3, double deg) {
  double temp[16];

  Matrix_rotatex(temp,deg);         /* Construct a x rotation matrix */
  Matrix_multiply(p3->model_mat,temp,p3->model_mat);
  Plot3D_maketransform(p3);

}

/* ----------------------------------------------------------------------
   Plot3D_roty(Plot3D *p3, double deg)

   Rotate the model around its y axis.
   ---------------------------------------------------------------------- */

void
Plot3D_roty(Plot3D *p3, double deg) {
  double temp[16];

  Matrix_rotatey(temp,deg);         /* Construct a y rotation matrix */
  Matrix_multiply(p3->model_mat,temp,p3->model_mat);
  Plot3D_maketransform(p3);

}

/* ----------------------------------------------------------------------
   Plot3D_rotz(Plot3D *p3, double deg)

   Rotate the model around its z axis.
   ---------------------------------------------------------------------- */

void
Plot3D_rotz(Plot3D *p3, double deg) {
  double temp[16];

  Matrix_rotatez(temp,deg);         /* Construct a z rotation matrix */
  Matrix_multiply(p3->model_mat,temp,p3->model_mat);
  Plot3D_maketransform(p3);

}


/* ----------------------------------------------------------------------
   Plot3D_rotd(Plot3D *p3, double deg)

   Rotate the model down
   ---------------------------------------------------------------------- */

void
Plot3D_rotd(Plot3D *p3, double deg) {
  double temp[16];

  Matrix_rotatex(temp,deg);         /* Construct a x rotation matrix */
  Matrix_multiply(temp, p3->model_mat,p3->model_mat);
  Plot3D_maketransform(p3);

}
    

/* ----------------------------------------------------------------------
   Plot3D_rotu(Plot3D *p3, double deg)

   Rotate the model up
   ---------------------------------------------------------------------- */

void
Plot3D_rotu(Plot3D *p3, double deg) {
  double temp[16];

  Matrix_rotatex(temp,-deg);         /* Construct a x rotation matrix */
  Matrix_multiply(temp,p3->model_mat,p3->model_mat);
  Plot3D_maketransform(p3);

}


/* ----------------------------------------------------------------------
   Plot3D_rotr(Plot3D *p3, double deg)

   Rotate the model down
   ---------------------------------------------------------------------- */

void
Plot3D_rotr(Plot3D *p3, double deg) {
  double temp[16];

  Matrix_rotatey(temp,deg);         /* Construct a y rotation matrix */
  Matrix_multiply(temp, p3->model_mat,p3->model_mat);
  Plot3D_maketransform(p3);

}
    

/* ----------------------------------------------------------------------
   Plot3D_rotl(Plot3D *p3, double deg)

   Rotate the model left
   ---------------------------------------------------------------------- */

void
Plot3D_rotl(Plot3D *p3, double deg) {
  double temp[16];

  Matrix_rotatey(temp,-deg);         /* Construct a y rotation matrix */
  Matrix_multiply(temp,p3->model_mat,p3->model_mat);
  Plot3D_maketransform(p3);

}


/* ----------------------------------------------------------------------
   Plot3D_rotc(Plot3D *p3, double deg)

   Rotate the model around center point
   ---------------------------------------------------------------------- */

void
Plot3D_rotc(Plot3D *p3, double deg) {
  double temp[16];

  Matrix_rotatez(temp,-deg);         /* Construct a z rotation matrix */
  Matrix_multiply(temp,p3->model_mat,p3->model_mat);
  Plot3D_maketransform(p3);
}

/* -------------------------------------------------------------------------
   Plot3D_zoom(Plot3D *p3, double percent)

   Zooms in or out the current image.   percent defines a percentage of
   zoom.

   Zooming is actually done by adjusting the perspective field of view
   instead of scaling the model or moving in the viewpoint.    This
   seems to work the best.
   ------------------------------------------------------------------------- */

void
Plot3D_zoom(Plot3D *p3, double percent) {

  double scale;
  double dx;
  if (percent <= 0) return;
  scale = percent/100.0;

  dx = (1.0/scale - 1.0)/(2*p3->zoom); /* Don't even ask where this came from */
  p3->xshift += dx;
  p3->yshift += dx;
  p3->zoom = p3->zoom*scale;

#ifdef OLD
  p3->fovy = p3->fovy*scale;
  if (p3->fovy > 170.0) p3->fovy = 170.0;
  if (p3->fovy == 0) p3->fovy = 0.0001;
  Plot3D_lookat(p3,p3->lookatz);
  Plot3D_perspective(p3,p3->fovy,p3->znear,p3->zfar);
#endif
}

/* --------------------------------------------------------------------------
   Plot3D_left(Plot3D *p3, double s)

   Shifts the image to the left by s units.   This is a little funky.

   s is scaled so that s = 100 equals one full screen.
   -------------------------------------------------------------------------- */
void
Plot3D_left(Plot3D *p3, double s) {
  p3->xshift -= (s/100.0)/p3->zoom;
}

/* --------------------------------------------------------------------------
   Plot3D_right(Plot3D *p3, double s)

   Shifts the image to the right by s units. 

   s is scaled so that s = 100 equals one full screen.
   -------------------------------------------------------------------------- */
void
Plot3D_right(Plot3D *p3, double s) {
  p3->xshift += (s/100.0)/p3->zoom;
}

/* --------------------------------------------------------------------------
   Plot3D_up(Plot3D *p3, double s)

   Shifts the image up left by s units.

   s is scaled so that s = 100 equals one full screen.
   -------------------------------------------------------------------------- */
void
Plot3D_up(Plot3D *p3, double s) {
  p3->yshift += (s/100.0)/p3->zoom;
}

/* --------------------------------------------------------------------------
   Plot3D_down(Plot3D *p3, double s)

   Shifts the image down by s units.  

   s is scaled so that s = 100 equals one full screen.
   -------------------------------------------------------------------------- */
void
Plot3D_down(Plot3D *p3, double s) {
  p3->yshift -= (s/100.0)/p3->zoom;
}

/* -------------------------------------------------------------------------
   Plot3D_center(Plot3D *p3, double cx, double cy)

   Centers the image on a point in the range (0,0) - (100,100)
   ------------------------------------------------------------------------- */
void
Plot3D_center(Plot3D *p3, double cx, double cy) {
  Plot3D_left(p3,cx-50);
  Plot3D_down(p3,cy-50);
}



/***************************************************************************
 *                       3d Primitives                                     *
 ***************************************************************************/

/* -------------------------------------------------------------------------
   Plot3D_horizontal(Plot3D *p3, int xmin, int xmax, int y, double z1, double z2, Pixel color)

   Draws a "Horizontal" line on the framebuffer between two screen coordinates,
   but also supplies z-values and zbuffering.   This function probably isn't
   too useful by itself, but will be used by a number of other primitives.
   -------------------------------------------------------------------------- */

void Plot3D_horizontal(Plot3D *p3, int xmin, int xmax, int y, Zvalue z1, Zvalue z2, Pixel color) {
  Pixel  *p;
  FrameBuffer *f;
  int     i;
  Zvalue  *zbuf,z,mz;
  int     startx, endx;

  f = p3->frame;
  if ((y < f->ymin) || (y >= f->ymax)) return;
  if (xmin > f->xmax) return;
  if (xmin < f->xmin) startx = f->xmin;
  else startx = xmin;
  if (xmax < f->xmin) return;
  if (xmax >= f->xmax) endx = f->xmax - 1;
  else endx = xmax;

  /* Calculate z slope */

  if (xmax != xmin) {
    mz = (Zvalue) ((double) (z2 - z1)/(double) (xmax - xmin));
  } else {
    mz = 0;
  }

  /* Draw it */
  
  p = &f->pixels[y][startx];
  zbuf = &f->zbuffer[y][startx];
  z = (Zvalue) (mz*(startx-xmin) + z1);
  for (i = startx; i <= endx; i++, p++, zbuf++,z+=mz) {
    if (z <= *zbuf) {
      *p = color;
      *zbuf = z;
    }
  }
}


/* -------------------------------------------------------------------------
   Plot3D_vertical(Plot3D *p3, int ymin, int ymax, int x, double z1, double z2, Pixel color)

   Draws a "Vertical" line on the framebuffer between two screen coordinates,
   but also supplies z-values and zbuffering.   This function probably isn't
   too useful by itself, but will be used by a number of other primitives.
   -------------------------------------------------------------------------- */

void Plot3D_vertical(Plot3D *p3, int ymin, int ymax, int x, Zvalue z1, Zvalue z2, Pixel color) {
  Pixel  *p;
  FrameBuffer *f;
  int     i;
  Zvalue  *zbuf,z,mz;
  int     starty, endy;

  f = p3->frame;
  if ((x < f->xmin) || (x >= f->xmax)) return;
  if (ymin >= f->ymax) return;
  if (ymin < f->ymin) starty = f->ymin;
  else starty = ymin;
  if (ymax < f->ymin) return;
  if (ymax >= f->ymax) endy = f->ymax - 1;
  else endy = ymax;

  /* Calculate z slope */

  mz = (double) (z2 - z1)/(double) (ymax - ymin);

  /* Draw it */
  
  p = &f->pixels[starty][x];
  zbuf = &f->zbuffer[starty][x];
  for (i = starty; i <= endy; i++, p+=f->width, zbuf+=f->width) {
    z = (Zvalue) (mz*(i-ymin) + z1);
    if (z <= *zbuf) {
      *p = color;
      *zbuf = z;
    }
  }
}

/* -------------------------------------------------------------------------------
   Plot3D_linetransform(Plot3D *p3, int x1, int y1, Zvalue z1,
                                    int x2, int y2, Zvalue z2, Pixel c)

   Draw a 3D line between points that have already been transformed into
   3D space.

   Uses a Bresenham line algorithm, but with linear interpolation between
   Zvalues.
   ------------------------------------------------------------------------------- */
   
void
Plot3D_linetransform(Plot3D *p3, int x1, int y1, Zvalue z1, int x2, int y2, Zvalue z2, Pixel c) {

  int       orig_x1, orig_y1, orig_x2,orig_y2;
  Zvalue    zt;
  
  /* Bresenham line drawing parameters */
  FrameBuffer *f;
  int  dx,dy,dxneg,dyneg, inc1,inc2,di;
  int  x, y, xpixels, ypixels, xt, yt;
  Pixel *p;
  double m;
  int  end1 = 0, end2 = 0;
  Zvalue  *zbuf,mz,z;

  f = p3->frame;
    
  /* Need to figure out where in the heck this line is */

  dx = x2 - x1;
  dy = y2 - y1;

  if ((dx == 0) && (dy == 0)) {
    if ((x1 < f->xmin) || (x1 >= f->xmax) ||
	(y1 < f->ymin) || (y1 >= f->ymax)) return;
    if (z1 <= f->zbuffer[y1][x1]) {
      f->pixels[y1][x1] = c;
    }
    return;
  }
  if (dx == 0) {
    /* Draw a Vertical Line */
    if (y1 < y2)
      Plot3D_vertical(p3,y1,y2,x1,z1,z2,c);
    else
      Plot3D_vertical(p3,y2,y1,x1,z2,z1,c);
    return;
  }
  if (dy == 0) {
    /* Draw a Horizontal Line */
    if (x1 < x2)
      Plot3D_horizontal(p3,x1,x2,y1,z1,z2,c);
    else
      Plot3D_horizontal(p3,x2,x1,y1,z2,z1,c);
    return;
  }

  /* Figure out where in the heck these lines are using the
     Cohen-Sutherland Line Clipping Scheme. */

  end1 = ((x1 - f->xmin) < 0) |
    (((f->xmax- 1 - x1) < 0) << 1) |
    (((y1 - f->ymin) < 0) << 2) |
    (((f->ymax-1 - y1) < 0) << 3);

  end2 = ((x2 - f->xmin) < 0) |
    (((f->xmax-1 - x2) < 0) << 1) |
    (((y2 - f->ymin) < 0) << 2) |
    (((f->ymax-1 - y2) < 0) << 3);

  if (end1 & end2) return;      /* Nope : Not visible */
  
  /* Make sure points have a favorable orientation */
  
  if (x1 > x2) {
    xt = x1;
    x1 = x2;
    x2 = xt;
    yt = y1;
    y1 = y2;
    y2 = yt;
    zt = z1;
    z1 = z2;
    z2 = zt;
  }

  /* Save original points before we clip them off */
  orig_x1 = x1;
  orig_y1 = y1;
  orig_x2 = x2;
  orig_y2 = y2;
  
  /* Clip against the boundaries */
  m = (y2 - y1)/(double) (x2-x1);
  if (x1 < f->xmin) {
    y1 = (f->xmin - x1)*m + y1;
    x1 = f->xmin;
  }
  if (x2 >= f->xmax) {
    y2 = (f->xmax -1 -x1)*m + y1;
    x2 = f->xmax - 1;
  }

  if (y1 > y2) {
    xt = x1;
    x1 = x2;
    x2 = xt;
    yt = y1;
    y1 = y2;
    y2 = yt;
    zt = z1;
    z1 = z2;
    z2 = zt;

    /* Swap original points */

    xt = orig_x1;
    orig_x1 = orig_x2;
    orig_x2 = xt;
    yt = orig_y1;
    orig_y1 = orig_y2;
    orig_y2 = yt;
  }

  m = 1/m;
  if (y1 < f->ymin) {
    x1 = (f->ymin - y1)*m + x1;
    y1 = f->ymin;
  }
  if (y2 >= f->ymax) {
    x2 = (f->ymax-1-y1)*m + x1;
    y2 = f->ymax-1;
  }

  if ((x1 < f->xmin) || (x1 >= f->xmax) || (y1 < f->ymin) || (y1 >= f->ymax) ||
      (x2 < f->xmin) || (x2 >= f->xmax) || (y2 < f->ymin) || (y2 >= f->ymax)) return;

  dx = x2 - x1;
  dy = y2 - y1;
  xpixels = f->width;
  ypixels = f->height;
  
  dxneg = (dx < 0) ? 1 : 0;
  dyneg = (dy < 0) ? 1 : 0;
  
  dx = abs(dx);
  dy = abs(dy);
  if (dx >= dy) {
    /* Slope between -1 and 1. */
    mz = (z2 - z1)/(orig_x2 - orig_x1);    /* Z interpolation slope */
    if (dxneg) {
      x = x1;
      y = y1;
      x1 = x2;
      y1 = y2;
      x2 = x;
      y2 = y;
      dyneg = !dyneg;
    }
    inc1 = 2*dy;
    inc2 = 2*(dy-dx);
    di = 2*dy-dx;

    /* Draw a line using x as independent variable */
    
    p = &f->pixels[y1][x1];
    zbuf = &f->zbuffer[y1][x1];
    x = x1;
    while (x <= x2) {
      /* Do a z-buffer check */
      z = mz*(x-orig_x1)+z1;
      if (z <= *zbuf){
	*p = c;
	*zbuf = z;
      }
      p++;
      zbuf++;
      if (di < 0) {
	di = di + inc1;
      } else {
	if (dyneg) {
	  p = p - xpixels;
	  zbuf = zbuf - xpixels;
	  di = di + inc2;
	} else {
	  p = p + xpixels;
	  zbuf = zbuf + xpixels;
	  di = di + inc2;
	}
      }
      x++;
    }
  } else {
    /* Slope < -1 or > 1 */
    mz = (z2 - z1)/(double) (orig_y2 - orig_y1);
    if (dyneg) {
      x = x1;
      y = y1;
      x1 = x2;
      y1 = y2;
      x2 = x;
      y2 = y;
      dxneg = !dxneg;
    }
    inc1 = 2*dx;
    inc2 = 2*(dx-dy);
    di = 2*dx-dy;

    /* Draw a line using y as independent variable */
    
    p = &f->pixels[y1][x1];
    zbuf = &f->zbuffer[y1][x1];
    y = y1;
    while (y <= y2) {
      /* Do a z-buffer check */
      z = mz*(y-orig_y1)+z1;
      if (z <= *zbuf) {
	*p = c;
	*zbuf = z;
      }
      p = p + xpixels;
      zbuf = zbuf + xpixels;
      if (di < 0) {
	di = di + inc1;
      } else {
	if (dxneg) {
	  p = p - 1;
	  zbuf = zbuf - 1;
	  di = di + inc2;
	} else {
	  p = p + 1;
	  zbuf = zbuf + 1;
	  di = di + inc2;
	}
      }
      y++;
    }
  }    
}

/* ---------------------------------------------------------------------------
   Plot3D_line(Plot3D *p3, double x1, double y1, double z1, double x2, double y2, double z2,int color)

   Draws a line in 3D space.   This is done as follows (for lack of a better
   method).

   1.  The points (x1,y1,z1) and (x2,y2,z2) are transformed into screen coordinates
   2.  We draw the line using a modified Bresenham line algorithm.
   3.  Zbuffer values are linearly interpolated between the two points.
   ---------------------------------------------------------------------------- */

void
Plot3D_line(Plot3D *p3, double fx1, double fy1, double fz1, double fx2, double fy2,
	    double fz2, Pixel c) {

  /* 3D Transformation parameters */
  GL_Vector t;
  double    invw;
  int       x1,y1,x2,y2;
  Zvalue    z1,z2;
  
  /* Transform the two points into screen coordinates */
  
  Matrix_transform4(p3->trans_mat,fx1,fy1,fz1,1,&t);  /* Point 1 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  x1 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  y1 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  z1 = t.z;
  
  Matrix_transform4(p3->trans_mat,fx2,fy2,fz2,1,&t);  /* Point 2 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  x2 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  y2 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  z2 = t.z;
  Plot3D_linetransform(p3,x1,y1,z1,x2,y2,z2,c);
}


/* -------------------------------------------------------------------------
   Plot3D_triangle(Plot3D *p3, double x1, double y1, double z1,
                               double x2, double y2, double z2,
			       double x3, double y3, double z3,
			       Pixel fillcolor)

   This function draws a 3D z-buffered outline triangle.
   -------------------------------------------------------------------------- */

void Plot3D_triangle(Plot3D *p3, double x1, double y1, double z1,
		     double x2, double y2, double z2,
		     double x3, double y3, double z3, Pixel color) {

  int        tx1, tx2, tx3, ty1, ty2, ty3;
  Zvalue     tz1, tz2, tz3;
  GL_Vector  t;
  double     invw;
  
  /* Transform the three points into screen coordinates */

  Matrix_transform4(p3->trans_mat,x1,y1,z1,1,&t);  /* Point 1 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx1 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty1 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz1 = (Zvalue) t.z;
  
  Matrix_transform4(p3->trans_mat,x2,y2,z2,1,&t);  /* Point 2 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx2 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty2 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz2 = (Zvalue) t.z;

  Matrix_transform4(p3->trans_mat,x3,y3,z3,1,&t);  /* Point 3 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx3 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty3 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz3 = (Zvalue) t.z;


  Plot3D_linetransform(p3,tx1,ty1,tz1,tx2,ty2,tz2,color);
  Plot3D_linetransform(p3,tx1,ty1,tz1,tx3,ty3,tz3,color);
  Plot3D_linetransform(p3,tx2,ty2,tz2,tx3,ty3,tz3,color);
}


/* -------------------------------------------------------------------------
   Plot3D_solidtriangletransform(Plot3D *p3, int tx1, int ty2, Zvalue tz1,
                                 int tx2, int ty2, Zvalue tz2,
				 int tx3, int ty3, Zvalue tz3, Pixel color) 

   This function draws a 3D z-buffered filled triangle.   Assumes three
   points have already been transformed into screen coordinates.

   General idea :
         1.   Transform the three points into screen coordinates
	 2.   Order three points vertically on screen.
	 3.   Check for degenerate cases (where 3 points are colinear).
	 4.   Fill in the resulting triangle using horizontal lines.
   -------------------------------------------------------------------------- */

void Plot3D_solidtriangletransform(Plot3D *p3, int tx1, int ty1, Zvalue tz1,
				   int tx2, int ty2, Zvalue tz2,
				   int tx3, int ty3, Zvalue tz3, Pixel color) {
  int        tempx, tempy;
  Zvalue     tempz;
  double     m1,m2,m3, mz1, mz2, mz3;
  int        y;
  int        ix1, ix2;
  Zvalue     zz1, zz2;
  FrameBuffer *f;
  register   double fy1,fy2;
  register   Zvalue fz1,fz2;

  f = p3->frame;

  /* Check for degenerate cases here */

  if ((ty1 == ty2) && (ty2 == ty3)) {
    if (tx2 < tx1) {   /* Swap points 1 and 2 if 2 is higher */
      tempx = tx1;
      tempz = tz1;
      tx1 = tx2;
      tz1 = tz2;
      tx2 = tempx;
      tz2 = tempz;
    }
    if (tx3 < tx1) {  /* Swap points 1 and 3 if 3 is higher */
      tempx = tx1;
      tempz = tz1;
      tx1 = tx3;
      tz1 = tz3;
      tx3 = tempx;
      tz3 = tempz;
    }
    if (tx3 < tx2) { /* Swap points 2 and 3 if 3 is higher */ 
      tempx = tx2;
      tempz = tz2;
      tx2 = tx3;
      tz2 = tz3;
      tx3 = tempx;
      tz3 = tempz;
    }

    /* Points are aligned horizontally.   Handle as a special case */
    /* Just draw three lines using the outline color */

    Plot3D_horizontal(p3,tx1,tx2,ty1,tz1,tz3,color);

    /*    Plot3D_linetransform(p3,tx1,ty1,tz1,tx2,ty2,tz2,color);
    Plot3D_linetransform(p3,tx1,ty1,tz1,tx3,ty3,tz3,color);
    Plot3D_linetransform(p3,tx2,ty2,tz2,tx3,ty3,tz3,color);
    */

    return;
  }

  /* Figure out which point has the greatest "y" value */

  if (ty2 > ty1) {   /* Swap points 1 and 2 if 2 is higher */
    tempx = tx1;
    tempy = ty1;
    tempz = tz1;
    tx1 = tx2;
    ty1 = ty2;
    tz1 = tz2;
    tx2 = tempx;
    ty2 = tempy;
    tz2 = tempz;
  }
  if (ty3 > ty1) {  /* Swap points 1 and 3 if 3 is higher */
    tempx = tx1;
    tempy = ty1;
    tempz = tz1;
    tx1 = tx3;
    ty1 = ty3;
    tz1 = tz3;
    tx3 = tempx;
    ty3 = tempy;
    tz3 = tempz;
  }
  if (ty3 > ty2) { /* Swap points 2 and 3 if 3 is higher */ 
    tempx = tx2;
    tempy = ty2;
    tempz = tz2;
    tx2 = tx3;
    ty2 = ty3;
    tz2 = tz3;
    tx3 = tempx;
    ty3 = tempy;
    tz3 = tempz;
  }

  /* Points are now order so that t_1 is the highest point, t_2 is the
     middle point, and t_3 is the lowest point */

    if (ty2 < ty1) {
      /* First process line segments between (x1,y1)-(x2,y2)
	 And between (x1,y1),(x3,y3) */

      m1 = (double) (tx2 - tx1)/(double) (ty2 - ty1);
      m2 = (double) (tx3 - tx1)/(double) (ty3 - ty1);
      mz1 = (tz2 - tz1)/(double) (ty2 - ty1);
      mz2 = (tz3 - tz1)/(double) (ty3 - ty1);

      y = ty1;
      fy1 = m1*(y-ty1)+0.5 + tx1;
      fy2 = m2*(y-ty1)+0.5 + tx1;
      fz1 = mz1*(y-ty1) + tz1;
      fz2 = mz2*(y-ty1) + tz1;
      while (y >= ty2) {
	/* Replace with bresenham scheme */
	/* Calculate x values from slope */
	ix1 = (int) fy1;
	ix2 = (int) fy2;
	zz1 = fz1;
	zz2 = fz2;
	fy1-= m1;
	fy2-= m2;
	fz1-= mz1;
	fz2-= mz2;
	if (ix1 > ix2) 
	  Plot3D_horizontal(p3,ix2,ix1,y,zz2,zz1,color);
	else
	  Plot3D_horizontal(p3,ix1,ix2,y,zz1,zz2,color);
	y--;
      }
    }
    if (ty3 < ty2) {
      /* Draw lower half of the triangle */
      m2 = (double) (tx3 - tx1)/(double) (ty3 - ty1);
      m3 = (double) (tx3 - tx2)/(double)(ty3 - ty2);
      mz2 = (tz3 - tz1)/(double) (ty3 - ty1);
      mz3 = (tz3 - tz2)/(double) (ty3 - ty2);
      y = ty2;
      while (y >= ty3) {
	ix1 = (int) (m3*(y-ty2)+0.5)+tx2;
	ix2 = (int) (m2*(y-ty1)+0.5)+tx1;
	zz1 = mz3*(y-ty2)+tz2;
	zz2 = mz2*(y-ty1)+tz1;
	if (ix1 > ix2)
	  Plot3D_horizontal(p3,ix2,ix1,y,zz2,zz1,color);
	else
	  Plot3D_horizontal(p3,ix1,ix2,y,zz1,zz2,color);
	y--;
      }
    }
}

/* -------------------------------------------------------------------------
   Plot3D_solidtriangle(Plot3D *p3, double x1, double y1, double z1,
                               double x2, double y2, double z2,
			       double x3, double y3, double z3,
			       Pixel color)

   This function draws a 3D z-buffered filled triangle.    Can be used to
   draw other primitives such as quadralaterals, etc...

   This function simply transforms the given points and calls
   Plot3D_SolidTriangleTransform().
   -------------------------------------------------------------------------- */

void Plot3D_solidtriangle(Plot3D *p3, double x1, double y1, double z1,
			  double x2, double y2, double z2,
			  double x3, double y3, double z3, Pixel color) {

  int        tx1, tx2, tx3, ty1, ty2, ty3;
  Zvalue     tz1, tz2, tz3;
  GL_Vector  t;
  double     invw;
  Matrix     a;
  register double     xshift, yshift, zoom, width, height, view_xmin, view_ymin;

  a = p3->trans_mat;
  xshift = p3->xshift;
  yshift = p3->yshift;
  zoom = p3->zoom;
  height = p3->height;
  width = p3->width;
  view_xmin = p3->view_xmin;
  view_ymin = p3->view_ymin;

  /* Transform the three points into screen coordinates */

  t.w = a[12]*x1 + a[13]*y1 + a[14]*z1 + a[15];
  invw = 1.0/t.w;
  t.x = (a[0]*x1 + a[1]*y1 + a[2]*z1 + a[3])*invw;
  t.y = (a[4]*x1 + a[5]*y1 + a[6]*z1 + a[7])*invw;
  t.z = (a[8]*x1 + a[9]*y1 + a[10]*z1 + a[11])*invw;

  tx1 = (int) ((t.x +xshift)*zoom*width + 0.5) + view_xmin; 
  ty1 = (int) ((t.y +yshift)*zoom*height + 0.5) + view_ymin;
  tz1 = (Zvalue) t.z;


  t.w = a[12]*x2 + a[13]*y2 + a[14]*z2 + a[15];
  invw = 1.0/t.w;
  t.x = (a[0]*x2 + a[1]*y2 + a[2]*z2 + a[3])*invw;
  t.y = (a[4]*x2 + a[5]*y2 + a[6]*z2 + a[7])*invw;
  t.z = (a[8]*x2 + a[9]*y2 + a[10]*z2 + a[11])*invw;
  tx2 = (int) ((t.x +xshift)*zoom*width + 0.5) + view_xmin; 
  ty2 = (int) ((t.y +yshift)*zoom*height + 0.5) + view_ymin;
  tz2 = (Zvalue) t.z;

  t.w = a[12]*x3 + a[13]*y3 + a[14]*z3 + a[15];
  invw = 1.0/t.w;
  t.x = (a[0]*x3 + a[1]*y3 + a[2]*z3 + a[3])*invw;
  t.y = (a[4]*x3 + a[5]*y3 + a[6]*z3 + a[7])*invw;
  t.z = (a[8]*x3 + a[9]*y3 + a[10]*z3 + a[11])*invw;
  tx3 = (int) ((t.x +xshift)*zoom*width + 0.5) + view_xmin; 
  ty3 = (int) ((t.y +yshift)*zoom*height + 0.5) + view_ymin;
  tz3 = (Zvalue) t.z;

  Plot3D_solidtriangletransform(p3,tx1,ty1,tz1,tx2,ty2,tz2,tx3,ty3,tz3,color); 
  
}    


/* -------------------------------------------------------------------------
   Plot3D_horizontalinterp(Plot3D *p3, int xmin, int xmax, int y,
                           double z1, double z2, Pixel c1, Pixel c2)

   Draws a "Horizontal" line on the framebuffer between two screen coordinates,
   but also supplies z-values and zbuffering.  Performs a color interpolation
   between c1 and c2.  This is primarily used by the SolidTriangleInterp()
   function to give the illusion of smooth surfaces.
   -------------------------------------------------------------------------- */

void Plot3D_horizontalinterp(Plot3D *p3, int xmin, int xmax, int y,
			     Zvalue z1, Zvalue z2, Pixel c1, Pixel c2) {
  Pixel  *p;
  FrameBuffer *f;
  int     i;
  Zvalue  *zbuf,z,mz;
  double   mc;
  int     startx, endx;
  double   invdx;
  
  f = p3->frame;
  if ((y < f->ymin) || (y >= f->ymax)) return;
  if (xmin >= f->xmax) return;
  if (xmin < f->xmin) startx = f->xmin;
  else startx = xmin;
  if (xmax < f->xmin) return;
  if (xmax >= f->xmax) endx = f->xmax - 1;
  else endx = xmax;

  /* Calculate z slope */
  if (xmax != xmin) {
    invdx = 1.0/(double) (xmax-xmin);
  } else {
    invdx = 0;
  }

  mz = (Zvalue) (z2 - z1)*invdx;

  /* Calculate c slope */

  mc = (double) (c2 - c1)*invdx;
    
  /* Draw it */
  
  p = &f->pixels[y][startx];
  zbuf = &f->zbuffer[y][startx];
  for (i = startx; i <= endx; i++, p++, zbuf++) {
    z = (Zvalue) (mz*(i-xmin) + z1);
    if (z <= *zbuf) {
      *p = (Pixel) (mc*(i-xmin)+c1);
      *zbuf = z;
    }
  }
}

/* -------------------------------------------------------------------------
   Plot3D_interptriangletransform(Plot3D *p3,
                                  int tx1, int ty2, Zvalue tz1, Pixel c1,
                                  int tx2, int ty2, Zvalue tz2, Pixel c2,
				  int tx3, int ty3, Zvalue tz3, Pixel c3)

   This function draws a 3D z-buffered filled triangle with color
   interpolation.   Assumes three points have already been transformed
   into screen coordinates.

   General idea :
         1.   Transform the three points into screen coordinates
	 2.   Order three points vertically on screen.
	 3.   Check for degenerate cases (where 3 points are colinear).
	 4.   Fill in the resulting triangle using horizontal lines.
	 5.   Colors are interpolated between end points
   -------------------------------------------------------------------------- */

void Plot3D_interptriangletransform(Plot3D *p3,
				    int tx1, int ty1, Zvalue tz1, Pixel c1,
				    int tx2, int ty2, Zvalue tz2, Pixel c2,
				    int tx3, int ty3, Zvalue tz3, Pixel c3) {
  int        tempx, tempy;
  Zvalue     tempz;
  double     m1,m2,m3, mz1, mz2, mz3;
  double     mc1,mc2,mc3;
  Pixel      ic1,ic2,tempc;
  int        y;
  int        ix1, ix2;
  Zvalue     zz1, zz2;
  FrameBuffer *f;
  
  f = p3->frame;

  /* Figure out which point has the greatest "y" value */

  if (ty2 > ty1) {   /* Swap points 1 and 2 if 2 is higher */
    tempx = tx1;
    tempy = ty1;
    tempz = tz1;
    tempc = c1;
    tx1 = tx2;
    ty1 = ty2;
    tz1 = tz2;
    c1 = c2;
    tx2 = tempx;
    ty2 = tempy;
    tz2 = tempz;
    c2 = tempc;
  }
  if (ty3 > ty1) {  /* Swap points 1 and 3 if 3 is higher */
    tempx = tx1;
    tempy = ty1;
    tempz = tz1;
    tempc = c1;
    tx1 = tx3;
    ty1 = ty3;
    tz1 = tz3;
    c1 = c3;
    tx3 = tempx;
    ty3 = tempy;
    tz3 = tempz;
    c3 = tempc;
  }
  if (ty3 > ty2) { /* Swap points 2 and 3 if 3 is higher */ 
    tempx = tx2;
    tempy = ty2;
    tempz = tz2;
    tempc = c2;
    tx2 = tx3;
    ty2 = ty3;
    tz2 = tz3;
    c2 = c3;
    tx3 = tempx;
    ty3 = tempy;
    tz3 = tempz;
    c3 = tempc;
  }

  /* Points are now order so that t_1 is the highest point, t_2 is the
     middle point, and t_3 is the lowest point */

  /* Check for degenerate cases here */

  if ((ty1 == ty2) && (ty2 == ty3)) {

    /* Points are aligned horizontally.   Handle as a special case */
    /* Just draw three lines using the outline color */

    if (tx2 > tx1)
      Plot3D_horizontalinterp(p3,tx1,tx2,ty1,tz1,tz2,c1,c2);
    else
      Plot3D_horizontalinterp(p3,tx2,tx1,ty1,tz2,tz1,c2,c1);
    if (tx3 > tx1)
      Plot3D_horizontalinterp(p3,tx1,tx3,ty1,tz1,tz3,c1,c3);
    else
      Plot3D_horizontalinterp(p3,tx3,tx1,ty1,tz3,tz1,c3,c1);
    if (tx3 > tx2)
      Plot3D_horizontalinterp(p3,tx2,tx3,ty2,tz2,tz3,c2,c3);
    else
      Plot3D_horizontalinterp(p3,tx3,tx2,ty2,tz3,tz2,c3,c2);
    
  } else {

    /* First process line segments between (x1,y1)-(x2,y2)
       And between (x1,y1),(x3,y3) */

    if (ty2 < ty1) {
      m1 = (double) (tx2 - tx1)/(double) (ty2 - ty1);
      m2 = (double) (tx3 - tx1)/(double) (ty3 - ty1);
      mz1 = (tz2 - tz1)/(double) (ty2 - ty1);
      mz2 = (tz3 - tz1)/(double) (ty3 - ty1);
      mc1 = (c2 - c1)/(double) (ty2 - ty1);
      mc2 = (c3 - c1)/(double) (ty3 - ty1);

      y = ty1;
      while (y >= ty2) {
	/* Calculate x values from slope */
	ix1 = (int) (m1*(y-ty1)+0.5) + tx1;
	ix2 = (int) (m2*(y-ty1)+0.5) + tx1;
	zz1 = mz1*(y-ty1) + tz1;
	zz2 = mz2*(y-ty1) + tz1;
	ic1 = mc1*(y-ty1) + c1;
	ic2 = mc2*(y-ty1) + c1;
	if (ix1 > ix2) 
	  Plot3D_horizontalinterp(p3,ix2,ix1,y,zz2,zz1,ic2,ic1);
	else
	  Plot3D_horizontalinterp(p3,ix1,ix2,y,zz1,zz2,ic1,ic2);
	y--;
      }
    }
    if (ty3 < ty2) {
      /* Draw lower half of the triangle */
      m2 = (double) (tx3 - tx1)/(double) (ty3 - ty1);
      mz2 = (tz3 - tz1)/(double) (ty3 - ty1);
      mc2 = (c3 - c1)/(double) (ty3 - ty1);
      m3 = (double) (tx3 - tx2)/(double)(ty3 - ty2);
      mz3 = (tz3 - tz2)/(double) (ty3 - ty2);
      mc3 = (c3 - c2)/(double) (ty3 - ty2);
      y = ty2;
      while (y >= ty3) {
	ix1 = (int) (m3*(y-ty2)+0.5)+tx2;
	ix2 = (int) (m2*(y-ty1)+0.5)+tx1;
	zz1 = mz3*(y-ty2)+tz2;
	zz2 = mz2*(y-ty1)+tz1;
	ic1 = mc3*(y-ty2)+c2;
	ic2 = mc2*(y-ty1)+c1;
	if (ix1 > ix2)
	  Plot3D_horizontalinterp(p3,ix2,ix1,y,zz2,zz1,ic2,ic1);
	else
	  Plot3D_horizontalinterp(p3,ix1,ix2,y,zz1,zz2,ic1,ic2);
	y--;
      }
    }
  }
}

/* -------------------------------------------------------------------------
   Plot3D_interptriangle(Plot3D *p3,
                         double x1, double y1, double z1, Pixel c1,
			 double x2, double y2, double z2, Pixel c2,
			 double x3, double y3, double z3, Pixel c3)

   This function draws a 3D z-buffered filled triangle with color
   interpolation.

   This function simply transforms the given points and calls
   Plot3D_InterpTriangleTransform().
   -------------------------------------------------------------------------- */

void Plot3D_interptriangle(Plot3D *p3,
			   double x1, double y1, double z1, Pixel c1,
			   double x2, double y2, double z2, Pixel c2,
			   double x3, double y3, double z3, Pixel c3) {

  int        tx1, tx2, tx3, ty1, ty2, ty3;
  Zvalue     tz1, tz2, tz3;
  GL_Vector  t;
  double     invw;
  
  /* Transform the three points into screen coordinates */

  Matrix_transform4(p3->trans_mat,x1,y1,z1,1,&t);  /* Point 1 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx1 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty1 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz1 = (Zvalue) t.z;
  
  Matrix_transform4(p3->trans_mat,x2,y2,z2,1,&t);  /* Point 2 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx2 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty2 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz2 = (Zvalue) t.z;

  Matrix_transform4(p3->trans_mat,x3,y3,z3,1,&t);  /* Point 3 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx3 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty3 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz3 = (Zvalue) t.z;

  Plot3D_interptriangletransform(p3,tx1,ty1,tz1,c1,tx2,ty2,tz2,c2,tx3,ty3,tz3,c3);
}    

/* -------------------------------------------------------------------------
   Plot3D_quad(Plot3D *p3, double x1, double y1, double z1,
                           double x2, double y2, double z2,
    		           double x3, double y3, double z3,
			   double x4, double y4, double z4,
 		           Pixel fillcolor)

   This function draws a 3D outlined Quadralateral.  Used primarily for
   drawing meshes and other things.

   Plotting is done in the following order :
       (x1,y1,z1)  --> (x2,y2,z2)
       (x2,y2,z2)  --> (x3,y3,z3)
       (x3,y3,z3)  --> (x4,y4,z4)
       (x4,y4,z4)  --> (x1,y1,z1)
   -------------------------------------------------------------------------- */

void Plot3D_quad(Plot3D *p3, double x1, double y1, double z1,
		 double x2, double y2, double z2,
		 double x3, double y3, double z3,
		 double x4, double y4, double z4,
		 Pixel color) {

  int        tx1, tx2, tx3, tx4, ty1, ty2, ty3, ty4;
  Zvalue     tz1, tz2, tz3, tz4;
  GL_Vector  t;
  double     invw;
  
  /* Transform the three points into screen coordinates */

  Matrix_transform4(p3->trans_mat,x1,y1,z1,1,&t);  /* Point 1 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx1 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty1 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz1 = (Zvalue) t.z;
  
  Matrix_transform4(p3->trans_mat,x2,y2,z2,1,&t);  /* Point 2 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx2 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty2 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz2 = (Zvalue) t.z;

  Matrix_transform4(p3->trans_mat,x3,y3,z3,1,&t);  /* Point 3 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx3 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty3 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz3 = (Zvalue) t.z;

  Matrix_transform4(p3->trans_mat,x4,y4,z4,1,&t);  /* Point 3 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx4 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty4 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz4 = (Zvalue) t.z;

  Plot3D_linetransform(p3,tx1,ty1,tz1,tx2,ty2,tz2,color);
  Plot3D_linetransform(p3,tx2,ty2,tz2,tx3,ty3,tz3,color);
  Plot3D_linetransform(p3,tx3,ty3,tz3,tx4,ty4,tz4,color);
  Plot3D_linetransform(p3,tx4,ty4,tz4,tx1,ty1,tz1,color);
  
}


/* -------------------------------------------------------------------------
   Plot3D_solidquad(Plot3D *p3, double x1, double y1, double z1,
                           double x2, double y2, double z2,
    		           double x3, double y3, double z3,
			   double x4, double y4, double z4,
 		           Pixel fillcolor)

   This function draws a 3D solid Quadralateral. Uses the function
   Plot3D_SolidTriangleTransform() to fill in the region.

   Plotting is done in the following order :
       (x1,y1,z1)  --> (x2,y2,z2)
       (x2,y2,z2)  --> (x3,y3,z3)
       (x3,y3,z3)  --> (x4,y4,z4)
       (x4,y4,z4)  --> (x1,y1,z1)
   -------------------------------------------------------------------------- */

void Plot3D_solidquad(Plot3D *p3, double x1, double y1, double z1,
		 double x2, double y2, double z2,
		 double x3, double y3, double z3,
		 double x4, double y4, double z4,
		 Pixel color) {

  int        tx1, tx2, tx3, tx4, ty1, ty2, ty3, ty4;
  Zvalue     tz1, tz2, tz3, tz4;
  GL_Vector  t;
  double     invw;
  
  /* Transform the three points into screen coordinates */

  Matrix_transform4(p3->trans_mat,x1,y1,z1,1,&t);  /* Point 1 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx1 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty1 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz1 = (Zvalue) t.z;
  
  Matrix_transform4(p3->trans_mat,x2,y2,z2,1,&t);  /* Point 2 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx2 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty2 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz2 = (Zvalue) t.z;

  Matrix_transform4(p3->trans_mat,x3,y3,z3,1,&t);  /* Point 3 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx3 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty3 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz3 = (Zvalue) t.z;

  Matrix_transform4(p3->trans_mat,x4,y4,z4,1,&t);  /* Point 3 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx4 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty4 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz4 = (Zvalue) t.z;

  Plot3D_solidtriangletransform(p3,tx1,ty1,tz1,tx2,ty2,tz2,tx3,ty3,tz3,color);
  Plot3D_solidtriangletransform(p3,tx1,ty1,tz1,tx4,ty4,tz4,tx3,ty3,tz3,color);
}

/* -------------------------------------------------------------------------
   Plot3D_interpquad(Plot3D *p3, double x1, double y1, double z1, Pixel c1,
                           double x2, double y2, double z2, Pixel c2,
    		           double x3, double y3, double z3, Pixel c3,
			   double x4, double y4, double z4, Pixel c4)

   This function draws a 3D color-interpolated Quadralateral. Uses the function
   Plot3D_InterpTriangleTransform() to fill in the region.

   Plotting is done in the following order :
       (x1,y1,z1)  --> (x2,y2,z2)
       (x2,y2,z2)  --> (x3,y3,z3)
       (x3,y3,z3)  --> (x4,y4,z4)
       (x4,y4,z4)  --> (x1,y1,z1)
   -------------------------------------------------------------------------- */

void Plot3D_interpquad(Plot3D *p3, double x1, double y1, double z1, Pixel c1,
		       double x2, double y2, double z2, Pixel c2,
		       double x3, double y3, double z3, Pixel c3,
		       double x4, double y4, double z4, Pixel c4) {


  int        tx1, tx2, tx3, tx4, ty1, ty2, ty3, ty4;
  Zvalue     tz1, tz2, tz3, tz4;
  GL_Vector  t;
  double     invw;
  
  /* Transform the three points into screen coordinates */

  Matrix_transform4(p3->trans_mat,x1,y1,z1,1,&t);  /* Point 1 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx1 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty1 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz1 = (Zvalue) t.z;
  
  Matrix_transform4(p3->trans_mat,x2,y2,z2,1,&t);  /* Point 2 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx2 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty2 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz2 = (Zvalue) t.z;

  Matrix_transform4(p3->trans_mat,x3,y3,z3,1,&t);  /* Point 3 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx3 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty3 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz3 = (Zvalue) t.z;

  Matrix_transform4(p3->trans_mat,x4,y4,z4,1,&t);  /* Point 3 */
  invw = 1.0/t.w;
  t.x = t.x *invw;
  t.y = t.y *invw;
  t.z = t.z *invw;
  tx4 = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty4 = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz4 = (Zvalue) t.z;

  Plot3D_interptriangletransform(p3,tx1,ty1,tz1,c1,tx2,ty2,tz2,c2,tx3,ty3,tz3,c3);
  Plot3D_interptriangletransform(p3,tx1,ty1,tz1,c1,tx4,ty4,tz4,c4,tx3,ty3,tz3,c3);
  
}

/* --------------------------------------------------------------------------
   Plot3D_solidsphere(Plot3 *p3, double x, double y, double z, double radius,
                      Pixel c)

   Makes a 3D sphere at x,y,z with given radius and color. 

   Basic strategy :
      1.  Transform point to screen coordinates
      2.  Figure out what the radius is in screen coordinates
      3.  Use bresenham algorithm for large spheres
      4.  Use bitmaps for small spheres
   -------------------------------------------------------------------------- */

/* This is used to fill in spheres */
static int s_xmin;
static int s_ymin;
static int s_xmax;
static int s_ymax;
static Pixel **s_pixels;
static Zvalue **s_zbuffer;

void Plot3D_spherehorizontal(int xmin, int xmax, int y, Zvalue z, Pixel color) {
  int     i;
  int     startx, endx;
  Pixel   *p;
  Zvalue  *zbuf;
  
  if ((y < s_ymin) || (y >= s_ymax)) return;
  if (xmin < s_xmin) startx = s_xmin;
  else startx = xmin;
  if (xmax >= s_xmax) endx = s_xmax - 1;
  else endx = xmax;

  /* Draw it */
  
  p = &s_pixels[y][xmin];
  zbuf = &s_zbuffer[y][xmin];
  for (i = startx; i <= endx; i++, p++, zbuf++) {
    if (z <= *zbuf) {
      *p = color;
      *zbuf = z;
    }
  }
}

void Plot3D_solidsphere(Plot3D *p3, double x, double y, double z, double radius,
			Pixel c) {

  GL_Vector  t,r;
  double     rad;
  int        tx,ty, irad;
  Zvalue     tz;
  double     invw;
  int        ix, iy, ix1,ix2,p;
  FrameBuffer *f;

  /* First transform the point into model coordinates */

  Matrix_transform4(p3->fullmodel_mat,x,y,z,1,&t);  

  /* Now transform two points in order to find proper sphere radius */

  Matrix_transform4(p3->view_mat,t.x+radius,t.y,t.z,t.w,&r);  /* transform radius */
  Matrix_transform4(p3->view_mat,t.x,t.y,t.z,t.w,&t);

  invw = 1.0/t.w;
  t.x = t.x*invw;
  t.y = t.y*invw;
  t.z = t.z*invw;
  invw = 1.0/r.w;
  r.x = r.x*invw;
  r.y = r.y*invw;
  r.z = r.z*invw;
  invw = 1.0/r.w;
  
  rad = fabs(t.x - r.x);
  
  /* Transform everything into screen coordinates */
  
  tx = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz = (Zvalue) t.z;
  irad = (int) (p3->zoom*(rad*p3->width + 0.5));

  /* This is only a temporary solution (maybe). */
         
#define fill_zcircle(x,y,c) \
  ix1 = tx - x; \
  ix2 = tx + x; \
  if (ix1 < s_xmin) ix1 = s_xmin; \
  if (ix2 >= s_xmax) ix2 = s_xmax; \
  Plot3D_spherehorizontal(ix1,ix2,y,tz,c);
  
  f = p3->frame;
  s_xmin = f->xmin;
  s_ymin = f->ymin;
  s_xmax = f->xmax;
  s_ymax = f->ymax;
  s_pixels = f->pixels;
  s_zbuffer = f->zbuffer;
  if (irad <= 1) {
    /* Plot a single pixel */
    if ((tx >= f->xmin) && (tx < f->xmax)) {
      if ((ty >= f->ymin) && (ty <f->ymax)) {
        if (tz <= f->zbuffer[ty][tx]) {
	  f->pixels[ty][tx] = c;
	  f->zbuffer[ty][tx] = tz;
	}
      }
    }
    return;
  }
  ix = 0;
  iy = irad;
  p = 3-2*irad;
  while (ix <= iy) {
    fill_zcircle(ix,ty+iy,c);
    fill_zcircle(ix,ty-iy,c);
    fill_zcircle(iy,ty+ix,c);
    fill_zcircle(iy,ty-ix,c);
    if (p < 0) p = p + 4*ix + 6;
    else {
      p = p + 4*(ix-iy) + 10;
      iy = iy -1;
    }
    ix++;
  }
}


/* --------------------------------------------------------------------
   Plot3D_outlinesphere(Plot3D *p3, double x, double y, double z,
                        double radius, Pixel color, Pixel bc)

   Draws an outlined sphere.
   -------------------------------------------------------------------- */

void Plot3D_outlinesphere(Plot3D *p3, double x, double y, double z,
			  double radius, Pixel c, Pixel bc)
{
  GL_Vector  t,r;
  double     rad;
  int        tx,ty, irad;
  Zvalue     tz;
  double     invw;
  int        ix, iy, ix1,ix2,p;
  
  FrameBuffer *f;

  /* First transform the point into model coordinates */

  Matrix_transform4(p3->fullmodel_mat,x,y,z,1,&t);  

  /* Now transform two points in order to find proper sphere radius */

  Matrix_transform4(p3->view_mat,t.x+radius,t.y,t.z,t.w,&r);  /* transform radius */
  Matrix_transform4(p3->view_mat,t.x,t.y,t.z,t.w,&t);

  invw = 1.0/t.w;
  t.x = t.x*invw;
  t.y = t.y*invw;
  t.z = t.z*invw;
  invw = 1.0/r.w;
  r.x = r.x*invw;
  r.y = r.y*invw;
  r.z = r.z*invw;
  invw = 1.0/r.w;
  
  rad = fabs(t.x - r.x);
  
  /* Transform everything into screen coordinates */
  
  tx = (int) ((t.x +p3->xshift)*p3->zoom*p3->width + 0.5) + p3->view_xmin; 
  ty = (int) ((t.y +p3->yshift)*p3->zoom*p3->height + 0.5) + p3->view_ymin;
  tz = (Zvalue) t.z;
  irad = (int) (p3->zoom*(rad*p3->width + 0.5));

  /* This is only a temporary solution (maybe). */
#define plot_zcircle(x,y,c) \
   if ((x >= s_xmin) && (x < s_xmax) && \
       (y >= s_ymin) && (y < s_ymax)) {\
         if (tz <= s_zbuffer[y][x]) { \
             s_pixels[y][x] = c; \
	     s_zbuffer[y][x] = tz; } \
   }
     
  f = p3->frame;
  s_xmin = f->xmin;
  s_ymin = f->ymin;
  s_xmax = f->xmax;
  s_ymax = f->ymax;
  s_pixels = f->pixels;
  s_zbuffer = f->zbuffer;
  
  if (irad <= 1) {
    /* Plot a single pixel */
    if ((tx >= f->xmin) && (tx < f->xmax)) {
      if ((ty >= f->ymin) && (ty <f->ymax)) {
        if (tz <= f->zbuffer[ty][tx]) {
	  f->pixels[ty][tx] = c;
	  f->zbuffer[ty][tx] = tz;
	}
      }
    }
    return;
  }
  ix = 0;
  iy = irad;
  p = 3-2*irad;
  while (ix <= iy) {
    fill_zcircle(ix,ty+iy,c);
    fill_zcircle(ix,ty-iy,c);
    fill_zcircle(iy,ty+ix,c);
    fill_zcircle(iy,ty-ix,c);
    
    plot_zcircle(tx+ix,ty+iy,bc);
    plot_zcircle(tx-ix,ty+iy,bc);
    plot_zcircle(tx+ix,ty-iy,bc);
    plot_zcircle(tx-ix,ty-iy,bc);
    plot_zcircle(tx+iy,ty+ix,bc);
    plot_zcircle(tx-iy,ty+ix,bc);
    plot_zcircle(tx+iy,ty-ix,bc);
    plot_zcircle(tx-iy,ty-ix,bc);
    if (p < 0) p = p + 4*ix + 6;
    else {
      p = p + 4*(ix-iy) + 10;
      iy = iy -1;
    }
    ix++;
  }
}

/* QUAD Test
   Test out quad functions for graphing */

double zf(double x, double y) {
  return cos(sqrt(x*x + y*y)*10.0)/(sqrt(x*x+y*y)+1);
}

void Quad_Test(Plot3D *p3, int npoints) {
  int i,j;
  double dx;
  double x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,za;
  int c;
  dx = 2.0/npoints;

  
  for (i = 0; i < npoints; i++)
    for (j = 0; j < npoints; j++) {
      x1 = i*dx + -1.0;
      y1 = j*dx + -1.0;
      x2 = x1 + dx;
      x3 = x1 + dx;
      x4 = x1;
      y2 = y1;
      y3 = y1 + dx;
      y4 = y1 + dx;
      z1 = zf(x1,y1);
      z2 = zf(x2,y2);
      z3 = zf(x3,y3);
      z4 = zf(x4,y4);
      za = 0.25*(z1+z2+z3+z4);
      c = 16+((za + 1)*120);
      if (c > 254) c = 254;
      Plot3D_quad(p3,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,(Pixel) c);
    }
}


void Quad_SolidTest(Plot3D *p3, int npoints) {
  int i,j;
  double dx;
  double x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,za;
  int c;
  dx = 2.0/npoints;

  
  for (i = 0; i < npoints; i++)
    for (j = 0; j < npoints; j++) {
      x1 = i*dx + -1.0;
      y1 = j*dx + -1.0;
      x2 = x1 + dx;
      x3 = x1 + dx;
      x4 = x1;
      y2 = y1;
      y3 = y1 + dx;
      y4 = y1 + dx;
      z1 = zf(x1,y1);
      z2 = zf(x2,y2);
      z3 = zf(x3,y3);
      z4 = zf(x4,y4);
      za = 0.25*(z1+z2+z3+z4);
      c = 16+((za + 1)*120);
      if (c > 254) c = 254;
      Plot3D_solidquad(p3,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,(Pixel) c);
    }
}



void Quad_InterpTest(Plot3D *p3, int npoints) {
  int i,j;
  double dx;
  double x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4;
  int c1,c2,c3,c4;
  dx = 2.0/npoints;

  
  for (i = 0; i < npoints; i++)
    for (j = 0; j < npoints; j++) {
      x1 = i*dx + -1.0;
      y1 = j*dx + -1.0;
      x2 = x1 + dx;
      x3 = x1 + dx;
      x4 = x1;
      y2 = y1;
      y3 = y1 + dx;
      y4 = y1 + dx;
      z1 = zf(x1,y1);
      z2 = zf(x2,y2);
      z3 = zf(x3,y3);
      z4 = zf(x4,y4);
      c1 = 16+((z1 + 1)*120);
      c2 = 16+((z2 + 1)*120);
      c3 = 16+((z3 + 1)*120);
      c4 = 16+((z4 + 1)*120);
      if (c1 > 254) c1 = 254;
      if (c2 > 254) c2 = 254;
      if (c3 > 254) c3 = 254;
      if (c4 > 254) c4 = 254;
      Plot3D_interpquad(p3,x1,y1,z1,(Pixel) c1,x2,y2,z2,(Pixel) c2,x3,y3,z3,(Pixel) c3,x4,y4,z4,(Pixel) c4);
    }
}



  
  
  
   


  
  
  
