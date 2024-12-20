#include <ruby.h>
#include "chdb.h"

// Debug configuration
#define CHDB_DEBUG 0
#if CHDB_DEBUG
#define DEBUG_PRINT(fmt, ...) fprintf(stderr, fmt "\n", ##__VA_ARGS__)
#else
#define DEBUG_PRINT(fmt, ...) ((void)0)
#endif

// Constants
#define CHDB_MAX_ARGS 256

VALUE cChdbError;

// Define a Ruby wrapper for `local_result_v2`
typedef struct {
    struct local_result_v2 *c_result;
} LocalResult;

static void local_result_free(void *ptr) {
    LocalResult *result = (LocalResult *)ptr;
    DEBUG_PRINT("Freeing LocalResult: %p", (void*)result);
    if (result->c_result) {
        free_result_v2(result->c_result);
    }
    free(result);
}

static VALUE local_result_alloc(VALUE klass) {
    LocalResult *result = ALLOC(LocalResult);
    DEBUG_PRINT("Allocating LocalResult: %p", (void*)result);
    result->c_result = NULL;
    return Data_Wrap_Struct(klass, NULL, local_result_free, result);
}

static VALUE local_result_initialize(VALUE self, VALUE argc, VALUE argv) {
    DEBUG_PRINT("Initializing LocalResult with %d arguments", NUM2INT(argc));

    // Type checking
    Check_Type(argc, T_FIXNUM);
    Check_Type(argv, T_ARRAY);

    int c_argc = NUM2INT(argc);
    if (c_argc < 0) {
        rb_raise(rb_eArgError, "Argument count cannot be negative");
    }
    if (c_argc > CHDB_MAX_ARGS) {
        rb_raise(rb_eArgError, "Too many arguments (max: %d)", CHDB_MAX_ARGS);
    }

    char **c_argv = ALLOC_N(char *, c_argc);

    for (int i = 0; i < c_argc; i++) {
        VALUE arg = rb_ary_entry(argv, i);
        c_argv[i] = StringValueCStr(arg);
    }

    LocalResult *result;
    Data_Get_Struct(self, LocalResult, result);

    // Execute query
    result->c_result = query_stable_v2(c_argc, c_argv);

    if (!result->c_result) {
        xfree(c_argv);
        rb_gc_unregister_address(&argv);
        rb_raise(cChdbError, "chDB query returned nil");
    }

    if (result->c_result->error_message) {
        VALUE error_message = rb_str_new_cstr(result->c_result->error_message);
        // Create error context
        VALUE context = rb_hash_new();
        rb_hash_aset(context, ID2SYM(rb_intern("args")), argv);
        rb_hash_aset(context, ID2SYM(rb_intern("error")), error_message);

        xfree(c_argv);
        rb_gc_unregister_address(&argv);
        rb_raise(cChdbError, "chDB error: %s", StringValueCStr(error_message));
    }

    xfree(c_argv);
    rb_gc_unregister_address(&argv);
    DEBUG_PRINT("LocalResult initialization complete");
    return self;
}

static VALUE local_result_buf(VALUE self) {
    LocalResult *result;
    Data_Get_Struct(self, LocalResult, result);

    if (!result->c_result || !result->c_result->buf) {
        DEBUG_PRINT("Buffer access attempted on empty result");
        return Qnil;
    }

    DEBUG_PRINT("Returning buffer of length %zu", result->c_result->len);
    return rb_str_new(result->c_result->buf, result->c_result->len);
}

static VALUE local_result_elapsed(VALUE self) {
    LocalResult *result;
    Data_Get_Struct(self, LocalResult, result);
    DEBUG_PRINT("Query elapsed time: %f", result->c_result->elapsed);
    return DBL2NUM(result->c_result->elapsed);
}

void Init_chdb() {
    DEBUG_PRINT("Initializing chdb extension");

    VALUE mChdb = rb_define_module("Chdb");
    cChdbError = rb_define_class_under(mChdb, "Error", rb_eStandardError);

    VALUE cLocalResult = rb_define_class_under(mChdb, "LocalResult", rb_cObject);
    rb_define_alloc_func(cLocalResult, local_result_alloc);
    rb_define_method(cLocalResult, "initialize", local_result_initialize, 2);
    rb_define_method(cLocalResult, "buf", local_result_buf, 0);
    rb_define_method(cLocalResult, "elapsed", local_result_elapsed, 0);

    DEBUG_PRINT("chdb extension initialized successfully");
}