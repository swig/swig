/* -----------------------------------------------------------------------------
 * Type initialization:
 * This problem is made tough by the requirement that no dynamic
 * memory is used. Also, since swig_type_info structures store pointers to
 * swig_cast_info structures and swig_cast_info structures store pointers back
 * to swig_type_info structures, we need some lookup code at initialization.
 * The idea is that swig generates all the structures that are needed.
 * The runtime then collects these partially filled structures.
 * The SWIG_InitializeModule function takes these initial arrays out of
 * swig_module, and does all the lookup, filling in the swig_module.types
 * array with the correct data and linking the correct swig_cast_info
 * structures together.
 *
 * The generated swig_type_info structures are assigned statically to an initial
 * array. We just loop through that array, and handle each type individually.
 * First we lookup if this type has been already loaded, and if so, use the
 * loaded structure instead of the generated one. Then we have to fill in the
 * cast dependencies. The cast data is initially stored in something like a
 * two-dimensional array. Each row corresponds to a type (there are the same
 * number of rows as there are in the swig_type_initial array). Each entry in
 * a column is one of the swig_cast_info structures for that type.
 * The cast_initial array is actually an array of arrays, because each row has
 * a variable number of columns.
 *
 * We loop through the cast[] array associated with the type and mark casts
 * which have not been defined in previously loaded modules by assigning
 * cast pointer value to cast->next. We also hash cast->type->name string
 * and store the value in the cast->value field. If we encounter swig_cast_info
 * structure that represents a cast to self we move it to the beginning
 * of the cast array. One trick we need to do is making sure the type pointer
 * in the swig_cast_info struct is correct.
 *
 * First off, we lookup the cast->type name to see if it is already loaded.
 * There are three cases to handle:
 *  1) If the cast->type has already been loaded AND the type we are adding
 *     casting info to has not been loaded (it is in this module), THEN we
 *     replace the cast->type pointer with the type pointer that has already
 *     been loaded.
 *  2) If BOTH types (the one we are adding casting info to, and the
 *     cast->type) are loaded, THEN the cast info has already been loaded by
 *     the previous module so we just ignore it.
 *  3) Finally, if cast->type has not already been loaded, then we add that
 *     swig_cast_info to the list (because the cast->type) pointer will
 *     be correct.
 *
 * Once the cast array has been set up AND it does have new casts that need
 * to be added we sort non-self cast entries to move filtered out entries
 * to the end of the array and to arrange the rest in the increasing order
 * of their type pointer values. We store the index of the last added entry
 * in the cast->value field of the entry[0] (overwriting the name hash). Then
 * we sort <next|value> fields of the remaining entries to arrange hash values
 * in the increasing order. This way cast->next->type->name field matches
 * the cast->value hash.
 *
 * Example:
 * Array of casts for type stored at 0x5000, cast to type stored at 0x3000
 * has already been loaded
 *
 *      After sweep-and-hash:   After sort-by-type:    After sort-by-hash:
 *        ________________       ________________       ________________
 *       |                |     |                |     |                |
 * Entry |  type = 0x5000 |     |  type = 0x5000 |     |  type = 0x5000 |
 *   0   |                |     |                |     |                |
 *       |  next = Entry0 |     |  next = Entry0 |     |  next = Entry0 |
 *       | value = 1212   |     | value = 3      |     | value = 3      |
 *       |                |     |                |     |                |
 *       |================|     |================|     |================|
 *       |                |     |                |     |                |
 * Entry |  type = 0x2000 |     |  type = 0x1000 |     |  type = 0x1000 |
 *   1   |                |     |                |     |                |
 *       |  next = Entry1 |     |  next = Entry1 |     |  next = Entry3 |
 *       | value = 3434   |     | value = 4545   |     | value = 2323   |
 *       |________________|     |________________|     |________________|
 *       |                |     |                |     |                |
 * Entry |  type = 0x3000 |     |  type = 0x2000 |     |  type = 0x2000 |
 *   2   |                |     |                |     |                |
 *       |  next = 0      |     |  next = Entry2 |     |  next = Entry2 |
 *       | value = 0      |     | value = 3434   |     | value = 3434   |
 *       |________________|     |________________|     |________________|
 *       |                |     |                |     |                |
 * Entry |  type = 0x1000 |     |  type = 0x4000 |     |  type = 0x4000 |
 *   3   |                |     |                |     |                |
 *       |  next = Entry3 |     |  next = Entry3 |     |  next = Entry1 |
 *       | value = 4545   |     | value = 2323   |     | value = 4545   |
 *       |________________|     |________________|     |________________|
 *       |                |     |                |     |                |
 * Entry |  type = 0x4000 |     |  type = 0x3000 |     |  type = 0x3000 |
 *   4   |                |     |                |     |                |
 *       |  next = Entry4 |     |  next = 0      |     |  next = 0      |
 *       | value = 2323   |     | value = 0      |     | value = 0      |
 *       |________________|     |________________|     |________________|
 *
 * Once the cast array has been initialized, we use cast[0]->next field to link
 * it into the list of cast arrays for the type.
 *              ____    ____    ____
 * type->cast->|next|->|next|->|next|->0
 *             |----|  |----|  |----|
 *             |----|  |----|  |----|
 *             |----|  |----|  |----|
 *
 * Subsequent cast resolution works as follows:
 *
 * 1. Check whether the type matches the first entry in the current cast array.
 * 2. If not, then do a binary search over the (0:cast->value] interval using
 *    either type address or the hash value of the type name.
 * 3. If not found, then move over to the next cast array (cast[0]->next).
 *
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#if 0
} /* c-mode */
#endif
#endif

#if 0
#define SWIGRUNTIME_DEBUG
#endif

#ifndef SWIG_INIT_CLIENT_DATA_TYPE
#define SWIG_INIT_CLIENT_DATA_TYPE void *
#endif

/*
 * Sort function that puts cast entries with nonzero 'next' at the front
 * of the array while ordering them by addresses of their 'type' structs.
 */
SWIGINTERN int SWIG_CastCmpStruct(const void *pa, const void *pb) {
  swig_cast_info *pca = (swig_cast_info *)pa;
  swig_cast_info *pcb = (swig_cast_info *)pb;
  if (pca->type < pcb->type)
    return (pca->next || pcb->next == 0) ? -1 : 1;
  if (pca->type > pcb->type)
    return (pcb->next || pca->next == 0) ? 1 : -1;
  return 0;
}

/*
 * Shell-sort 'next' and 'value' field pairs to order them by 'value'.
 */
SWIGINTERN void SWIG_CastHashSort(swig_cast_info *cast, int size) {
  const int hmax = size/9;
  int h, i;
  for(h = 1; h <= hmax; h = 3*h+1);
  for(; h > 0; h /= 3)
  {
    for(i = h; i < size; ++i)
    {
      swig_cast_info *p = cast[i].next;
      unsigned int hash = cast[i].value;
      int j = i;
      while(j >= h && hash < cast[j-h].value)
      {
        cast[j].next = cast[j-h].next;
        cast[j].value = cast[j-h].value;
        j -= h;
      }
      cast[j].next = p;
      cast[j].value = hash;
    }
  }
}

SWIGRUNTIME void
SWIG_InitializeModule(SWIG_INIT_CLIENT_DATA_TYPE clientdata) {
  size_t i;
  swig_module_info *module_head, *iter;
  int init;

  /* check to see if the circular list has been setup, if not, set it up */
  if (swig_module.next==0) {
    /* Initialize the swig_module */
    swig_module.type_initial = swig_type_initial;
    swig_module.cast_initial = swig_cast_initial;
    swig_module.next = &swig_module;
    init = 1;
  } else {
    init = 0;
  }

  /* Try and load any already created modules */
  module_head = SWIG_GetModule(clientdata);
  if (!module_head) {
    /* This is the first module loaded for this interpreter */
    /* so set the swig module into the interpreter */
    SWIG_SetModule(clientdata, &swig_module);
  } else {
    /* the interpreter has loaded a SWIG module, but has it loaded this one? */
    iter=module_head;
    do {
      if (iter==&swig_module) {
        /* Our module is already in the list, so there's nothing more to do. */
        return;
      }
      iter=iter->next;
    } while (iter!= module_head);

    /* otherwise we must add our module into the list */
    swig_module.next = module_head->next;
    module_head->next = &swig_module;
  }

  /* When multiple interpreters are used, a module could have already been initialized in
     a different interpreter, but not yet have a pointer in this interpreter.
     In this case, we do not want to continue adding types... everything should be
     set up already */
  if (init == 0) return;

  /* Now work on filling in swig_module.types */
#ifdef SWIGRUNTIME_DEBUG
  printf("SWIG_InitializeModule: size %lu\n", (unsigned long)swig_module.size);
#endif
  for (i = 0; i < swig_module.size; ++i) {
    swig_type_info *type = 0;
    swig_type_info *target_type;
    swig_cast_info *cast, *first;
    int num_mapped = 0;

#ifdef SWIGRUNTIME_DEBUG
    printf("SWIG_InitializeModule: type %lu %s\n", (unsigned long)i, swig_module.type_initial[i]->name);
#endif

    /* if there is another module already loaded */
    if (swig_module.next != &swig_module) {
      type = SWIG_MangledTypeQueryModule(swig_module.next, &swig_module, swig_module.type_initial[i]->name);
    }
    if (type) {
      /* Overwrite clientdata field */
#ifdef SWIGRUNTIME_DEBUG
      printf("SWIG_InitializeModule: found type %s\n", type->name);
#endif
      if (swig_module.type_initial[i]->clientdata) {
	type->clientdata = swig_module.type_initial[i]->clientdata;
#ifdef SWIGRUNTIME_DEBUG
      printf("SWIG_InitializeModule: found and overwrite type %s \n", type->name);
#endif
      }
    } else {
      type = swig_module.type_initial[i];
    }

    /* Insert casting types */
    cast = first = swig_module.cast_initial[i];
    while (cast->type) {

      /* Don't need to add information already in the list */
      target_type = 0;
#ifdef SWIGRUNTIME_DEBUG
      printf("SWIG_InitializeModule: look cast %s\n", cast->type->name);
#endif
      if (swig_module.next != &swig_module) {
        target_type = SWIG_MangledTypeQueryModule(swig_module.next, &swig_module, cast->type->name);
        if (target_type) {

          /* Target type already defined in another module */
#ifdef SWIGRUNTIME_DEBUG
          printf("SWIG_InitializeModule: found cast %s\n", target_type->name);
#endif
          if (type == swig_module.type_initial[i]) {
#ifdef SWIGRUNTIME_DEBUG
            printf("SWIG_InitializeModule: skip old type %s\n", target_type->name);
#endif
            cast->type = target_type;
            target_type = 0;
          } else {
            /* Check if this cast is already in the list */
            swig_cast_info *ocast = SWIG_TypeCheck(target_type->name, type);
#ifdef SWIGRUNTIME_DEBUG
            if (ocast) printf("SWIG_InitializeModule: skip old cast %s\n", target_type->name);
#endif
            if (!ocast) target_type = 0;
          }
        }
      }

      if (!target_type) {
#ifdef SWIGRUNTIME_DEBUG
        printf("SWIG_InitializeModule: adding cast %s\n", cast->type->name);
#endif
        /* Set inclusion mark for sorting */
        cast->next = cast;
        num_mapped++;

        if (type == cast->type) {
#ifdef SWIGRUNTIME_DEBUG
          printf("%s : self cast at pos [%li]\n", type->name, cast - first);
#endif
          if (cast - first) {

            /* Move cast to itself to the first entry in the array */

            swig_cast_info tmp = *cast;
            *cast = *first;
            *first = tmp;
          }
          first++;

        } else {
          cast->value = SWIG_Hash(cast->type->name, (unsigned int)strlen(cast->type->name));
        }
      }
      cast++;
    }

    if (num_mapped) {
      if (cast - first) {
        swig_cast_info *tmp;

        /* Sort casts by type address for binary search in SWIG_TypeCheckStruct */
        qsort(first, cast - first, sizeof(swig_cast_info), SWIG_CastCmpStruct);

        /* Remap back links for added entries */
        cast = swig_module.cast_initial[i] + num_mapped;
        for (tmp = first; tmp < cast; tmp++) {
          tmp->next = tmp;
        }
      }

      /* Set the value field of the first entry to the index of the last added entry */
      cast = swig_module.cast_initial[i];
      cast->value = num_mapped - 1;

      num_mapped -= (int)(first - cast);
      if (num_mapped > 1) {
        /* Sort <'next','value'> pairs by 'value' for binary search in SWIG_TypeCheck */

        SWIG_CastHashSort(first, num_mapped);
      }

      first = type->cast;
      if (first) {
        /* Link the current set into the list of cast arrays */
        cast->next = first->next;
        first->next = cast;
      } else {
        cast->next = 0;
        type->cast = cast;
      }
    }

    /* Set entry in modules->types array equal to the type */
    swig_module.types[i] = type;
  }
  swig_module.types[i] = 0;

#ifdef SWIGRUNTIME_DEBUG
  printf("**** SWIG_InitializeModule: Cast List ******\n");
  for (i = 0; i < swig_module.size; ++i) {
    int j = 0;
    swig_cast_info *cast = swig_module.cast_initial[i];
    printf("SWIG_InitializeModule: type %lu %s\n", (unsigned long)i, swig_module.type_initial[i]->name);
    while (cast->type) {
      printf("SWIG_InitializeModule: cast type %s\n", cast->type->name);
      cast++;
      ++j;
    }
  printf("---- Total casts: %d\n",j);
  }
  printf("**** SWIG_InitializeModule: Cast List ******\n");
#endif
}

/* This function will propagate the clientdata field of type to
* any new swig_type_info structures that have been added into the list
* of equivalent types.  It is like calling
* SWIG_TypeClientData(type, clientdata) a second time.
*/
SWIGRUNTIME void
SWIG_PropagateClientData(void) {
  size_t i;
  static int init_run = 0;

  if (init_run) return;
  init_run = 1;

  for (i = 0; i < swig_module.size; i++) {
    if (swig_module.types[i]->clientdata) {
      swig_cast_info *head, *cast;
      head = swig_module.types[i]->cast;
      while (head) {
        for (cast = head; (cast - head) <= head->value; cast++) {
          if (!cast->converter) {
            if (cast->type && !cast->type->clientdata)
              SWIG_TypeClientData(cast->type, swig_module.types[i]->clientdata);
          }
        }
        head = head->next;
      }
    }
  }
}

#ifdef __cplusplus
#if 0
{ /* c-mode */
#endif
}
#endif
