/****************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 ****************************************************************************/

#include "swigcore.h"

/* -----------------------------------------------------------------------------
 * expr.c
 *
 * This is your basic ol' integer arithmetic expression evaluator.   Could have
 * used yacc for this, but it generates something like 1000 lines of code
 * (whereas this implementation is much smaller).
 *
 * This module is primarily for use by the preprocessor and any other parts of
 * the compiler that need to perform compile-time expression evaluation.
 * ----------------------------------------------------------------------------- */

static Scanner *scan = 0;

typedef struct { 
  int       op;
  long      value;
} exprval;

#define  EXPR_TOP      1
#define  EXPR_VALUE    2
#define  EXPR_OP       3
#define  EXPR_GROUP    4
#define  EXPR_UMINUS   100

static exprval stack[256];              /* Parsing stack       */
static int     sp = 0;                  /* Stack pointer       */
static int     prec[256];               /* Precedence rules    */
static int     expr_init = 0;           /* Initialization flag */
static char   *errmsg = 0;              /* Parsing error       */

/* Initialize the precedence table for various operators.  Low values have higher precedence */
static void init_precedence() {
  prec[TOKEN_NOT] = 10;              
  prec[EXPR_UMINUS] = 10;
  prec[TOKEN_STAR] = 20;             
  prec[TOKEN_SLASH] = 20;
  prec[TOKEN_PERCENT] = 20;
  prec[TOKEN_PLUS] = 30;             
  prec[TOKEN_MINUS] = 30;
  prec[TOKEN_LSHIFT] = 40;
  prec[TOKEN_RSHIFT] = 40;
  prec[TOKEN_AND] = 50;
  prec[TOKEN_XOR] = 60;
  prec[TOKEN_OR] = 70;
  prec[TOKEN_EQUALTO] = 80;
  prec[TOKEN_NOTEQUAL] = 80;
  prec[TOKEN_LESSTHAN] = 80;
  prec[TOKEN_GREATERTHAN] = 80;
  prec[TOKEN_LTEQUAL] = 80;
  prec[TOKEN_GTEQUAL] = 80;
  prec[TOKEN_LNOT] = 90;
  prec[TOKEN_LAND] = 100;
  prec[TOKEN_LOR] = 110;
  expr_init = 1;
}

/* Reduce a single operator on the stack */
static void reduce_op() {
  if (stack[sp-1].op != EXPR_OP) {
    errmsg = "Missing operator";
    sp = 0;
    return;
  }
  switch(stack[sp-1].value) {
  case TOKEN_STAR:
    stack[sp-2].value = stack[sp-2].value * stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_EQUALTO:
    stack[sp-2].value = stack[sp-2].value == stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_NOTEQUAL:
    stack[sp-2].value = stack[sp-2].value != stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_PLUS:
    stack[sp-2].value = stack[sp-2].value + stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_MINUS:
    stack[sp-2].value = stack[sp-2].value - stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_AND:
    stack[sp-2].value = stack[sp-2].value & stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_LAND:
    stack[sp-2].value = stack[sp-2].value && stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_OR:
    stack[sp-2].value = stack[sp-2].value | stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_LOR:
    stack[sp-2].value = stack[sp-2].value || stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_XOR:
    stack[sp-2].value = stack[sp-2].value ^ stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_LESSTHAN:
    stack[sp-2].value = stack[sp-2].value < stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_GREATERTHAN:
    stack[sp-2].value = stack[sp-2].value > stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_LTEQUAL:
    stack[sp-2].value = stack[sp-2].value <= stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_GTEQUAL:
    stack[sp-2].value = stack[sp-2].value >= stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_NOT:
    stack[sp-1].value = ~stack[sp].value;
    sp--;
    break;
  case TOKEN_LNOT:
    stack[sp-1].value = !stack[sp].value;
    sp--;
    break;
  case EXPR_UMINUS:
    stack[sp-1].value = -stack[sp].value;
    sp--;
    break;
  case TOKEN_SLASH:
    stack[sp-2].value = stack[sp-2].value / stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_PERCENT:
    stack[sp-2].value = stack[sp-2].value % stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_LSHIFT:
    stack[sp-2].value = stack[sp-2].value << stack[sp].value;
    sp -= 2;
    break;
  case TOKEN_RSHIFT:
    stack[sp-2].value = stack[sp-2].value >> stack[sp].value;
    sp -= 2;
    break;
  default:
    errmsg = "Syntax error";
    sp = 0;
    break;
  }
  stack[sp].op = EXPR_VALUE;
}

/* -----------------------------------------------------------------------------
 * void SWIG_expr_init()
 * 
 * Initialize the expression evaluator 
 * ----------------------------------------------------------------------------- */

void SWIG_expr_init() {
  if (!expr_init) init_precedence();
  if (!scan) scan = NewScanner();
}

/* -----------------------------------------------------------------------------
 * int SWIG_expr(DOH *s, int *error)
 *
 * Evaluates an arithmetic expression in s.
 * ----------------------------------------------------------------------------- */

int SWIG_expr(DOH *s, int *error) {
  int     token = 0;
  int     op = 0;
  
  sp = 0;
  assert(s);
  assert(scan);

  Seek(s,0,SEEK_SET);
  *error = 0;
  Scanner_clear(scan);
  Scanner_push(scan,s);

  /* Put initial state onto the stack */
  stack[sp].op = EXPR_TOP;
  stack[sp].value = 0;

  while (1) {
    /* Look at the top of the stack */
    switch(stack[sp].op) {
    case EXPR_TOP:
      /* An expression.   Can be a number or another expression enclosed in parens */
      token = Scanner_token(scan);
      if (!token) {
	errmsg = "Expected an expression";
	*error = 1;
	return 0;
      }
      if ((token == TOKEN_INT) || (token == TOKEN_UINT) || (token == TOKEN_LONG) || (token == TOKEN_ULONG)) {
	/* A number.  Reduce EXPR_TOP to an EXPR_VALUE */
	stack[sp].value = (long) atol(Char(Scanner_text(scan)));
	stack[sp].op = EXPR_VALUE;
      } else if (token == TOKEN_PLUS) { }
       else if ((token == TOKEN_MINUS) || (token == TOKEN_LNOT) || (token==TOKEN_NOT)) {
	if (token == TOKEN_MINUS) token = EXPR_UMINUS;
	stack[sp].value = token;
	stack[sp++].op = EXPR_OP;
	stack[sp].op = EXPR_TOP;
      } else if ((token == TOKEN_LPAREN)) {
	stack[sp++].op = EXPR_GROUP;
	stack[sp].op = EXPR_TOP;
	stack[sp].value = 0;
      } else if (token == TOKEN_ENDLINE) { }
      else goto syntax_error;
      break;
    case EXPR_VALUE:
      /* A value is on the stack.   We may reduce or evaluate depending on what the next token is */
      token = Scanner_token(scan);
      if (!token) {
	/* End of input. Might have to reduce if an operator is on stack */
	while (sp > 0) {
	  if (stack[sp-1].op == EXPR_OP) {
	    reduce_op();
	  } else if (stack[sp-1].op == EXPR_GROUP) {
	    errmsg = "Missing \')\'";
	    *error = 1;
	    return 0;
	  } else goto syntax_error;
	}
	return stack[sp].value;
      }
      /* Token must be an operator */
      switch(token) {
      case TOKEN_STAR:
      case TOKEN_EQUALTO:
      case TOKEN_NOTEQUAL:
      case TOKEN_PLUS:
      case TOKEN_MINUS:
      case TOKEN_AND:
      case TOKEN_LAND:
      case TOKEN_OR:
      case TOKEN_LOR:
      case TOKEN_XOR:
      case TOKEN_LESSTHAN:
      case TOKEN_GREATERTHAN:
      case TOKEN_LTEQUAL:
      case TOKEN_GTEQUAL:
      case TOKEN_SLASH:
      case TOKEN_PERCENT:
      case TOKEN_LSHIFT:
      case TOKEN_RSHIFT:
	if ((sp == 0) || (stack[sp-1].op == EXPR_GROUP)) {
	  /* No possibility of reduce. Push operator and expression */
	  sp++;
	  stack[sp].op = EXPR_OP;
	  stack[sp].value = token;
	  sp++;
	  stack[sp].op = EXPR_TOP;
	  stack[sp].value = 0;
	} else {
	  if (stack[sp-1].op != EXPR_OP) goto syntax_error;
	  op = stack[sp-1].value;         /* Previous operator */
	  
	  /* Now, depending on the precedence relationship between the last operator and the current
	     we will reduce or push */
	  
	  if (prec[op] <= prec[token]) {
	    /* Reduce the previous operator */
	    reduce_op();
	    if (stack[sp].op != EXPR_VALUE) goto syntax_error;
	  }
	  sp++;
	  stack[sp].op = EXPR_OP;
	  stack[sp].value = token;
	  sp++;
	  stack[sp].op = EXPR_TOP;
	  stack[sp].value = 0;
	}
	break;
      case TOKEN_RPAREN:
	if (sp ==  0) goto extra_rparen;
	
	/* Might have to reduce operators first */
	while ((sp > 0) && (stack[sp-1].op == EXPR_OP)) reduce_op();
	if ((sp == 0) || (stack[sp-1].op != EXPR_GROUP)) goto extra_rparen;
	stack[sp-1].op = EXPR_VALUE;
	stack[sp-1].value = stack[sp].value;
	sp--;
	break;
      default:
	goto syntax_error;
	break;
      }
      break;
    default:
      fprintf(stderr,"Internal error in expression evaluator.\n");
      abort();
    }
  }
 syntax_error:
  errmsg = "Syntax error";
  *error = 1;
  return 0;

 extra_rparen:
  errmsg = "Extra \')\'";
  *error = 1;
  return 0;
}

/* Return the expression error message */
char *SWIG_expr_error() {
  return errmsg;
}


  

  
  

