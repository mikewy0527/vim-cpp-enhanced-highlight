" Vim syntax file
" Language: C++ Additions
" Maintainer: Jon Haggblad <jon@haeggblad.com>
" URL: http://www.haeggblad.com
" Last Change: 29 Jun 2019
" Version: 0.6
" Changelog:
"   0.1 - initial version.
"   0.2 - C++14
"   0.3 - Incorporate lastest changes from Mizuchi/STL-Syntax
"   0.4 - Add template function highlight
"   0.5 - Redo template function highlight to be more robust. Add options.
"   0.6 - more C++14, C++17, library concepts
"
" Additional Vim syntax highlighting for C++ (including C++11/14/17)
"
" This file contains additional syntax highlighting that I use for C++11/14
" development in Vim. Compared to the standard syntax highlighting for C++ it
" adds highlighting of (user defined) functions and the containers and types
" in the standard library / boost.
"
" Based on:
"   http://stackoverflow.com/q/736701
"   http://www.vim.org/scripts/script.php?script_id=4293
"   http://www.vim.org/scripts/script.php?script_id=2224
"   http://www.vim.org/scripts/script.php?script_id=1640
"   http://www.vim.org/scripts/script.php?script_id=3064


" -----------------------------------------------------------------------------
"  Highlight Class and Function names.
"
" Based on the discussion in: http://stackoverflow.com/q/736701
" -----------------------------------------------------------------------------

" Base-on-user-config highlight settings ----------------------------------{{{
" Class and namespace scope
if get(g:, 'cpp_class_scope_highlight', 0)
    syn match   cppScopeDelimiter    "::"
    syn match   cCustomClass    "\w\+\s*::" contains=cppScopeDelimiter
    hi def link cCustomClass cppClassScope
endif

" Class name declaration
if get(g:, 'cpp_class_decl_highlight', 0)
    syn clear cppStructure
    syn match cCustomClassKey "\<class\>"
    syn match cCustomClassKey "\<typename\>"
    syn match cCustomClassKey "\<template\>"
    syn match cCustomClassKey "\<namespace\>"
    hi def link cCustomClassKey cppStructure

    " Clear cppAccess entirely and redefine as matches
    syn clear cppAccess
    syn match cCustomAccessKey "\<private\>"
    syn match cCustomAccessKey "\<public\>"
    syn match cCustomAccessKey "\<protected\>"
    hi def link cCustomAccessKey cppAccess

    " Match the parts of a class declaration
    syn match cCustomClassName "\<namespace\_s\+\w\+\>" contains=cCustomClassKey
    syn match cCustomClassName_2 "\<class\_s\+\w\+\>\_s*[:{;]"me=e-1 contains=cCustomClassKey
    syn region cCustomClassName start="\%(\<class\>\_s\+\w\+\)\@<=\zs\_s\+" end=":\|{\|;"me=e-1
              \ contains=cCustomClassKey,cString,cCustomFunc,cBraces
              \ nextgroup=cCustomClassName_2
    syn match cCustomClassName "\<private\_s\+\w\+\>" contains=cCustomAccessKey
    syn match cCustomClassName "\<public\_s\+\w\+\>" contains=cCustomAccessKey
    syn match cCustomClassName "\<protected\_s\+\w\+\>" contains=cCustomAccessKey
    hi def link cCustomClassName cppStructDeclare
    hi def link cCustomClassName_2 cppStructDeclare
endif
".}}}

" Template functions -------------------------------------------------------{{{
"
" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" Highlight method:
"   1. cpp_experimental_simple_template_highlight:
"       Naive implementation that sorta works in most cases. Should correctly
"       highlight everything in test/color2.cpp
"
"   2. cpp_experimental_template_highlight:
"       Template functions (alternative faster parsing).
"       More sophisticated implementation that should be faster but doesn't always
"       correctly highlight inside template arguments. Should correctly
"       highlight everything in test/color.cpp
" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if get(g:, 'cpp_experimental_simple_template_highlight', 0)
    syn match   cppScopeDelimiter   "::"
    syn match   myAngleBracketStart "<"
    syn match   myAngleBracketEnd   ">"

    if get(g:, 'cpp_operator_highlight', 0)
        hi def link myAngleBracketStart cppCustomOperator
        hi def link myAngleBracketEnd   cppCustomOperator
    endif

    syn region  cCustomAngleBrackets matchgroup=AngleBracketContents
                \ start="\v%(<operator\_s*)@<!%(%(\_i|template\_s*)@<=\<[<=]@!|\<@<!\<[[:space:]<=]@!)"ms=s+1
                \ end='(\|>\|{\|=\|\}\|\m;'me=e-1
                \ contains=@cppSTLgroup,cppStructure,cType,cCustomClass,cCustomAngleBrackets,cppNumber
                \ ,cppOperator,myAngleBracketStart,myAngleBracketEnd,cDelimiter,cppScopeDelimiter
                \ ,cSpecialDelimiter,cString,cBraces,cppSTLnamespace

    syn match   cCustomBrack    "<\|>"
                \ contains=cCustomAngleBrackets,myAngleBracketStart,myAngleBracketEnd
                \ ,cppScopeDelimiter,cppSTLnamespace

    syn match   cCustomTemplateFunc "\w\+\s*\(<.\+>\)\?(\@="
                \ contains=cCustromBrack,cCustomAngleBrackets,cCustomTemplateClass
                \ ,cStatement,cppStatement,cDelimiter,cppScopeDelimiter
                \ ,myAngleBracketStart,myAngleBracketEnd,cppSTLnamespace

    syn match   cCustomTemplateClass "\<\w\+\>\s*\(<\(\w\+::\)\?\w\+>\)\?::\@="
                \ contains=cCustomBrack,cCustomAngleBrackets,cppScopeDelimiter,cCustomFunc
                \ ,myAngleBracketStart,myAngleBracketEnd,cppSTLnamespace

    syn match   cCustomTemplateImpl "\<\w\+\>\s*<\w\+>\s"me=e-2
                \ contains=cCustromBrack,cCustomAngleBrackets,myAngleBracketStart,myAngleBracketEnd
                \ ,cppSTLnamespace

    hi def link cCustomTemplateImpl  cppTemplateImpl
    hi def link cCustomTemplateFunc  cFunction
    hi def link cCustomTemplateClass cppClassScope

elseif get(g:, 'cpp_experimental_template_highlight', 0)

    syn match   cCustomAngleBracketStart "<\_[^;()]\{-}>" contained
                \ contains=cCustomAngleBracketStart,cCustomAngleBracketEnd
    hi def link cCustomAngleBracketStart  cCustomAngleBracketContent

    syn match   cCustomAngleBracketEnd ">\_[^<>;()]\{-}>" contained
                \ contains=cCustomAngleBracketEnd
    hi def link cCustomAngleBracketEnd  cCustomAngleBracketContent

    syn match cCustomTemplateFunc "\<\l\w*\s*<\_[^;()]\{-}>(\@="hs=s,he=e-1
                \ contains=cCustomAngleBracketStart
    hi def link cCustomTemplateFunc  cCustomFunc

    syn match    cCustomTemplateClass    "\<\w\+\s*<\_[^;()]\{-}>"
                \ contains=cCustomAngleBracketStart,cCustomTemplateFunc
    hi def link cCustomTemplateClass cCustomClass

    syn match   cCustomTemplate "\<template\>"
    hi def link cCustomTemplate  cppStructure
    syn match   cTemplateDeclare "\<template\_s*<\_[^;()]\{-}>"
                \ contains=cppStructure,cCustomTemplate,cCustomClassKey,cCustomAngleBracketStart

    " Remove 'operator' from cppOperator and use a custom match
    syn clear cppOperator
    syn keyword cppOperator typeid
    syn keyword cppCustomOperator and bitor or xor compl bitand and_eq or_eq xor_eq not not_eq

    syn match   cppCustomOperator "\<operator\>"
    hi def link cppCustomOperator  cppOperator
    syn match   cTemplateOperatorDeclare "\<operator\_s*<\_[^;()]\{-}>[<>]=\?"
                \ contains=cppOperator,cppCustomOperator,cCustomAngleBracketStart
endif
".}}}

" Base settings -----------------------------------------------------------{{{
" Cluster for all the stdlib functions defined below
syn cluster cppSTLgroup contains=cppSTLfunction,cppSTLfunctional,cppConstant
                        \ ,cppSTLnamespace,cppType,cppSTLexception,cppSTLiterator
                        \ ,cppSTLiterator_tag,cppSTLenum,cppSTLios,cppSTLcast


" -----------------------------------------------------------------------------
"  Standard library types and functions.
"
" Mainly based on the excellent STL Syntax vim script by
" Mizuchi <ytj000@gmail.com>
"   http://www.vim.org/scripts/script.php?script_id=4293
" which in turn is based on the scripts
"   http://www.vim.org/scripts/script.php?script_id=2224
"   http://www.vim.org/scripts/script.php?script_id=1640
" -----------------------------------------------------------------------------

syntax keyword cppConstant badbit
syntax keyword cppConstant cerr
syntax keyword cppConstant cin
syntax keyword cppConstant clog
syntax keyword cppConstant cout
syntax keyword cppConstant digits
syntax keyword cppConstant digits10
syntax keyword cppConstant eofbit
syntax keyword cppConstant failbit
syntax keyword cppConstant goodbit
syntax keyword cppConstant has_denorm
syntax keyword cppConstant has_denorm_loss
syntax keyword cppConstant has_infinity
syntax keyword cppConstant has_quiet_NaN
syntax keyword cppConstant has_signaling_NaN
syntax keyword cppConstant is_bounded
syntax keyword cppConstant is_exact
syntax keyword cppConstant is_iec559
syntax keyword cppConstant is_integer
syntax keyword cppConstant is_modulo
syntax keyword cppConstant is_signed
syntax keyword cppConstant is_specialized
syntax keyword cppConstant max_digits10
syntax keyword cppConstant max_exponent
syntax keyword cppConstant max_exponent10
syntax keyword cppConstant min_exponent
syntax keyword cppConstant min_exponent10
syntax keyword cppConstant nothrow
syntax keyword cppConstant npos
syntax keyword cppConstant radix
syntax keyword cppConstant round_style
syntax keyword cppConstant tinyness_before
syntax keyword cppConstant traps
syntax keyword cppConstant wcerr
syntax keyword cppConstant wcin
syntax keyword cppConstant wclog
syntax keyword cppConstant wcout
syntax keyword cppExceptions bad_alloc
syntax keyword cppExceptions bad_array_new_length
syntax keyword cppExceptions bad_exception
syntax keyword cppExceptions bad_typeid bad_cast
syntax keyword cppExceptions domain_error
syntax keyword cppExceptions exception
syntax keyword cppExceptions invalid_argument
syntax keyword cppExceptions length_error
syntax keyword cppExceptions logic_error
syntax keyword cppExceptions out_of_range
syntax keyword cppExceptions overflow_error
syntax keyword cppExceptions range_error
syntax keyword cppExceptions runtime_error
syntax keyword cppExceptions underflow_error

syntax keyword cppSTLfunction abort
syntax keyword cppSTLfunction abs
syntax keyword cppSTLfunction accumulate
syntax keyword cppSTLfunction acos
syntax keyword cppSTLfunction adjacent_difference
syntax keyword cppSTLfunction adjacent_find
syntax keyword cppSTLfunction adjacent_find_if
syntax keyword cppSTLfunction advance

syntax keyword cppSTLfunctional binary_function
syntax keyword cppSTLfunctional binary_negate
syntax keyword cppSTLfunctional bit_and
syntax keyword cppSTLfunctional bit_not
syntax keyword cppSTLfunctional bit_or
syntax keyword cppSTLfunctional bit_xor
syntax keyword cppSTLfunctional divides
syntax keyword cppSTLfunctional equal_to
syntax keyword cppSTLfunctional greater
syntax keyword cppSTLfunctional greater_equal
syntax keyword cppSTLfunctional less
syntax keyword cppSTLfunctional less_equal
syntax keyword cppSTLfunctional logical_and
syntax keyword cppSTLfunctional logical_not
syntax keyword cppSTLfunctional logical_or
syntax keyword cppSTLfunctional minus
syntax keyword cppSTLfunctional modulus
syntax keyword cppSTLfunctional multiplies
syntax keyword cppSTLfunctional negate
syntax keyword cppSTLfunctional not_equal_to
syntax keyword cppSTLfunctional plus
syntax keyword cppSTLfunctional unary_function
syntax keyword cppSTLfunctional unary_negate

"syntax keyword cppSTLfunction any
syntax keyword cppSTLfunction append
syntax keyword cppSTLfunction arg
syntax keyword cppSTLfunction asctime
syntax keyword cppSTLfunction asin
syntax keyword cppSTLfunction assert
syntax keyword cppSTLfunction assign
syntax keyword cppSTLfunction at
syntax keyword cppSTLfunction atan
syntax keyword cppSTLfunction atan2
syntax keyword cppSTLfunction atexit
syntax keyword cppSTLfunction atof
syntax keyword cppSTLfunction atoi
syntax keyword cppSTLfunction atol
syntax keyword cppSTLfunction atoll
syntax keyword cppSTLfunction back
syntax keyword cppSTLfunction back_inserter
syntax keyword cppSTLfunction bad
syntax keyword cppSTLfunction beg
"syntax keyword cppSTLfunction begin
syntax keyword cppSTLfunction binary_compose
syntax keyword cppSTLfunction binary_negate
syntax keyword cppSTLfunction binary_search
syntax keyword cppSTLfunction bind1st
syntax keyword cppSTLfunction bind2nd
syntax keyword cppSTLfunction binder1st
syntax keyword cppSTLfunction binder2nd
syntax keyword cppSTLfunction bsearch
syntax keyword cppSTLfunction calloc
syntax keyword cppSTLfunction capacity
syntax keyword cppSTLfunction ceil
syntax keyword cppSTLfunction clear
syntax keyword cppSTLfunction clearerr
syntax keyword cppSTLfunction clock
syntax keyword cppSTLfunction close
syntax keyword cppSTLfunction compare
syntax keyword cppSTLfunction conj
syntax keyword cppSTLfunction construct
syntax keyword cppSTLfunction copy
syntax keyword cppSTLfunction copy_backward
syntax keyword cppSTLfunction cos
syntax keyword cppSTLfunction cosh
syntax keyword cppSTLfunction count
syntax keyword cppSTLfunction count_if
syntax keyword cppSTLfunction c_str
syntax keyword cppSTLfunction ctime
"syntax keyword cppSTLfunction data
syntax keyword cppSTLfunction denorm_min
syntax keyword cppSTLfunction destroy
syntax keyword cppSTLfunction difftime
syntax keyword cppSTLfunction distance
syntax keyword cppSTLfunction div
syntax keyword cppSTLfunction empty
"syntax keyword cppSTLfunction end
syntax keyword cppSTLfunction eof
syntax keyword cppSTLfunction epsilon
syntax keyword cppSTLfunction equal
syntax keyword cppSTLfunction equal_range
syntax keyword cppSTLfunction erase
syntax keyword cppSTLfunction exit
syntax keyword cppSTLfunction exp
syntax keyword cppSTLfunction fabs
syntax keyword cppSTLfunction fail
syntax keyword cppSTLfunction failure
syntax keyword cppSTLfunction fclose
syntax keyword cppSTLfunction feof
syntax keyword cppSTLfunction ferror
syntax keyword cppSTLfunction fflush
syntax keyword cppSTLfunction fgetc
syntax keyword cppSTLfunction fgetpos
syntax keyword cppSTLfunction fgets
syntax keyword cppSTLfunction fill
syntax keyword cppSTLfunction fill_n
syntax keyword cppSTLfunction find
syntax keyword cppSTLfunction find_end
syntax keyword cppSTLfunction find_first_not_of
syntax keyword cppSTLfunction find_first_of
syntax keyword cppSTLfunction find_if
syntax keyword cppSTLfunction find_last_not_of
syntax keyword cppSTLfunction find_last_of
syntax keyword cppSTLfunction first
syntax keyword cppSTLfunction flags
syntax keyword cppSTLfunction flip
syntax keyword cppSTLfunction floor
syntax keyword cppSTLfunction flush
syntax keyword cppSTLfunction fmod
syntax keyword cppSTLfunction fopen
syntax keyword cppSTLfunction for_each
syntax keyword cppSTLfunction fprintf
syntax keyword cppSTLfunction fputc
syntax keyword cppSTLfunction fputs
syntax keyword cppSTLfunction fread
syntax keyword cppSTLfunction free
syntax keyword cppSTLfunction freopen
syntax keyword cppSTLfunction frexp
syntax keyword cppSTLfunction front
syntax keyword cppSTLfunction fscanf
syntax keyword cppSTLfunction fseek
syntax keyword cppSTLfunction fsetpos
syntax keyword cppSTLfunction ftell
syntax keyword cppSTLfunction fwide
syntax keyword cppSTLfunction fwprintf
syntax keyword cppSTLfunction fwrite
syntax keyword cppSTLfunction fwscanf
syntax keyword cppSTLfunction gcount
syntax keyword cppSTLfunction generate
syntax keyword cppSTLfunction generate_n
syntax keyword cppSTLfunction get
syntax keyword cppSTLfunction get_allocator
syntax keyword cppSTLfunction getc
syntax keyword cppSTLfunction getchar
syntax keyword cppSTLfunction getenv
syntax keyword cppSTLfunction getline
syntax keyword cppSTLfunction gets
syntax keyword cppSTLfunction get_temporary_buffer
syntax keyword cppSTLfunction gmtime
syntax keyword cppSTLfunction good
syntax keyword cppSTLfunction ignore
syntax keyword cppSTLfunction imag
syntax keyword cppSTLfunction in
syntax keyword cppSTLfunction includes
syntax keyword cppSTLfunction infinity
syntax keyword cppSTLfunction inner_product
syntax keyword cppSTLfunction inplace_merge
syntax keyword cppSTLfunction insert
syntax keyword cppSTLfunction inserter
syntax keyword cppSTLfunction ios
syntax keyword cppSTLfunction ios_base
syntax keyword cppSTLfunction iostate
syntax keyword cppSTLfunction iota
syntax keyword cppSTLfunction isalnum
syntax keyword cppSTLfunction isalpha
syntax keyword cppSTLfunction iscntrl
syntax keyword cppSTLfunction isdigit
syntax keyword cppSTLfunction isgraph
syntax keyword cppSTLfunction is_heap
syntax keyword cppSTLfunction islower
syntax keyword cppSTLfunction is_open
syntax keyword cppSTLfunction isprint
syntax keyword cppSTLfunction ispunct
syntax keyword cppSTLfunction isspace
syntax keyword cppSTLfunction isupper
syntax keyword cppSTLfunction isxdigit
syntax keyword cppSTLfunction iterator_category
syntax keyword cppSTLfunction iter_swap
syntax keyword cppSTLfunction jmp_buf
syntax keyword cppSTLfunction key_comp
syntax keyword cppSTLfunction labs
syntax keyword cppSTLfunction ldexp
syntax keyword cppSTLfunction ldiv
syntax keyword cppSTLfunction length
syntax keyword cppSTLfunction lexicographical_compare
syntax keyword cppSTLfunction lexicographical_compare_3way
syntax keyword cppSTLfunction llabs
syntax keyword cppSTLfunction lldiv
syntax keyword cppSTLfunction localtime
syntax keyword cppSTLfunction log
syntax keyword cppSTLfunction log10
syntax keyword cppSTLfunction longjmp
syntax keyword cppSTLfunction lower_bound
syntax keyword cppSTLfunction make_heap
syntax keyword cppSTLfunction make_pair
syntax keyword cppSTLfunction malloc
syntax keyword cppSTLfunction max
syntax keyword cppSTLfunction max_element
syntax keyword cppSTLfunction max_size
syntax keyword cppSTLfunction memchr
syntax keyword cppSTLfunction memcpy
syntax keyword cppSTLfunction mem_fun
syntax keyword cppSTLfunction mem_fun_ref
syntax keyword cppSTLfunction memmove
syntax keyword cppSTLfunction memset
syntax keyword cppSTLfunction merge
syntax keyword cppSTLfunction min
syntax keyword cppSTLfunction min_element
syntax keyword cppSTLfunction mismatch
syntax keyword cppSTLfunction mktime
syntax keyword cppSTLfunction modf
syntax keyword cppSTLfunction next_permutation
syntax keyword cppSTLfunction none
syntax keyword cppSTLfunction norm
syntax keyword cppSTLfunction not1
syntax keyword cppSTLfunction not2
syntax keyword cppSTLfunction nth_element

syntax keyword cppSTLfunction open
syntax keyword cppSTLfunction partial_sort
syntax keyword cppSTLfunction partial_sort_copy
syntax keyword cppSTLfunction partial_sum
syntax keyword cppSTLfunction partition
syntax keyword cppSTLfunction peek
syntax keyword cppSTLfunction perror
syntax keyword cppSTLfunction polar
syntax keyword cppSTLfunction pop
syntax keyword cppSTLfunction pop_back
syntax keyword cppSTLfunction pop_front
syntax keyword cppSTLfunction pop_heap
syntax keyword cppSTLfunction pow
syntax keyword cppSTLfunction power
syntax keyword cppSTLfunction precision
syntax keyword cppSTLfunction prev_permutation
syntax keyword cppSTLfunction printf
syntax keyword cppSTLfunction ptr_fun
syntax keyword cppSTLfunction push
syntax keyword cppSTLfunction push_back
syntax keyword cppSTLfunction push_front
syntax keyword cppSTLfunction push_heap
syntax keyword cppSTLfunction put
syntax keyword cppSTLfunction putback
syntax keyword cppSTLfunction putc
syntax keyword cppSTLfunction putchar
syntax keyword cppSTLfunction puts
syntax keyword cppSTLfunction qsort
syntax keyword cppSTLfunction quiet_NaN
syntax keyword cppSTLfunction raise
syntax keyword cppSTLfunction rand
syntax keyword cppSTLfunction random_sample
syntax keyword cppSTLfunction random_sample_n
syntax keyword cppSTLfunction random_shuffle
syntax keyword cppSTLfunction rbegin
syntax keyword cppSTLfunction rdbuf
syntax keyword cppSTLfunction rdstate
syntax keyword cppSTLfunction read
syntax keyword cppSTLfunction real
syntax keyword cppSTLfunction realloc
syntax keyword cppSTLfunction remove
syntax keyword cppSTLfunction remove_copy
syntax keyword cppSTLfunction remove_copy_if
syntax keyword cppSTLfunction remove_if
syntax keyword cppSTLfunction rename
syntax keyword cppSTLfunction rend
syntax keyword cppSTLfunction replace
syntax keyword cppSTLfunction replace_copy
syntax keyword cppSTLfunction replace_copy_if
syntax keyword cppSTLfunction replace_if
syntax keyword cppSTLfunction reserve
syntax keyword cppSTLfunction reset
syntax keyword cppSTLfunction resize
syntax keyword cppSTLfunction return_temporary_buffer
syntax keyword cppSTLfunction reverse
syntax keyword cppSTLfunction reverse_copy
syntax keyword cppSTLfunction rewind
syntax keyword cppSTLfunction rfind
syntax keyword cppSTLfunction rotate
syntax keyword cppSTLfunction rotate_copy
syntax keyword cppSTLfunction round_error
syntax keyword cppSTLfunction scanf
syntax keyword cppSTLfunction search
syntax keyword cppSTLfunction search_n
syntax keyword cppSTLfunction second
syntax keyword cppSTLfunction seekg
syntax keyword cppSTLfunction seekp
syntax keyword cppSTLfunction setbuf
syntax keyword cppSTLfunction set_difference
syntax keyword cppSTLfunction setf
syntax keyword cppSTLfunction set_intersection
syntax keyword cppSTLfunction setjmp
syntax keyword cppSTLfunction setlocale
syntax keyword cppSTLfunction set_new_handler
syntax keyword cppSTLfunction set_symmetric_difference
syntax keyword cppSTLfunction set_union
syntax keyword cppSTLfunction setvbuf
syntax keyword cppSTLfunction signal
syntax keyword cppSTLfunction signaling_NaN
syntax keyword cppSTLfunction sin
syntax keyword cppSTLfunction sinh
"syntax keyword cppSTLfunction size
syntax keyword cppSTLfunction sort
syntax keyword cppSTLfunction sort_heap
syntax keyword cppSTLfunction splice
syntax keyword cppSTLfunction sprintf
syntax keyword cppSTLfunction sqrt
syntax keyword cppSTLfunction srand
syntax keyword cppSTLfunction sscanf
syntax keyword cppSTLfunction stable_partition
syntax keyword cppSTLfunction stable_sort
syntax keyword cppSTLfunction str
syntax keyword cppSTLfunction strcat
syntax keyword cppSTLfunction strchr
syntax keyword cppSTLfunction strcmp
syntax keyword cppSTLfunction strcoll
syntax keyword cppSTLfunction strcpy
syntax keyword cppSTLfunction strcspn
syntax keyword cppSTLfunction strerror
syntax keyword cppSTLfunction strftime
syntax keyword cppSTLfunction string
syntax keyword cppSTLfunction strlen
syntax keyword cppSTLfunction strncat
syntax keyword cppSTLfunction strncmp
syntax keyword cppSTLfunction strncpy
syntax keyword cppSTLfunction strpbrk
syntax keyword cppSTLfunction strrchr
syntax keyword cppSTLfunction strspn
syntax keyword cppSTLfunction strstr
syntax keyword cppSTLfunction strtod
syntax keyword cppSTLfunction strtof
syntax keyword cppSTLfunction strtok
syntax keyword cppSTLfunction strtol
syntax keyword cppSTLfunction strtold
syntax keyword cppSTLfunction strtoll
syntax keyword cppSTLfunction strtoul
syntax keyword cppSTLfunction strxfrm
syntax keyword cppSTLfunction substr
syntax keyword cppSTLfunction swap
syntax keyword cppSTLfunction swap_ranges
syntax keyword cppSTLfunction swprintf
syntax keyword cppSTLfunction swscanf
syntax keyword cppSTLfunction sync_with_stdio
"syntax keyword cppSTLfunction system
syntax keyword cppSTLfunction tan
syntax keyword cppSTLfunction tanh
syntax keyword cppSTLfunction tellg
syntax keyword cppSTLfunction tellp
"syntax keyword cppSTLfunction test
"syntax keyword cppSTLfunction time
syntax keyword cppSTLfunction tmpfile
syntax keyword cppSTLfunction tmpnam
syntax keyword cppSTLfunction tolower
syntax keyword cppSTLfunction top
syntax keyword cppSTLfunction to_string
syntax keyword cppSTLfunction to_ulong
syntax keyword cppSTLfunction toupper
syntax keyword cppSTLfunction to_wstring
syntax keyword cppSTLfunction transform
syntax keyword cppSTLfunction unary_compose
syntax keyword cppSTLfunction unget
syntax keyword cppSTLfunction ungetc
syntax keyword cppSTLfunction uninitialized_copy
syntax keyword cppSTLfunction uninitialized_copy_n
syntax keyword cppSTLfunction uninitialized_fill
syntax keyword cppSTLfunction uninitialized_fill_n
syntax keyword cppSTLfunction unique
syntax keyword cppSTLfunction unique_copy
syntax keyword cppSTLfunction unsetf
syntax keyword cppSTLfunction upper_bound
syntax keyword cppSTLfunction va_arg
syntax keyword cppSTLfunction va_copy
syntax keyword cppSTLfunction va_end
syntax keyword cppSTLfunction value_comp
syntax keyword cppSTLfunction va_start
syntax keyword cppSTLfunction vfprintf
syntax keyword cppSTLfunction vfwprintf
syntax keyword cppSTLfunction vprintf
syntax keyword cppSTLfunction vsprintf
syntax keyword cppSTLfunction vswprintf
syntax keyword cppSTLfunction vwprintf
syntax keyword cppSTLfunction width
syntax keyword cppSTLfunction wprintf
syntax keyword cppSTLfunction write
syntax keyword cppSTLfunction wscanf

syntax keyword cppSTLios boolalpha
syntax keyword cppSTLios dec
syntax keyword cppSTLios defaultfloat
syntax keyword cppSTLios endl
syntax keyword cppSTLios ends
syntax keyword cppSTLios fixed
syntax keyword cppSTLios floatfield
syntax keyword cppSTLios flush
syntax keyword cppSTLios get_money
syntax keyword cppSTLios get_time
syntax keyword cppSTLios hex
syntax keyword cppSTLios hexfloat
syntax keyword cppSTLios internal
syntax keyword cppSTLios noboolalpha
syntax keyword cppSTLios noshowbase
syntax keyword cppSTLios noshowpoint
syntax keyword cppSTLios noshowpos
syntax keyword cppSTLios noskipws
syntax keyword cppSTLios nounitbuf
syntax keyword cppSTLios nouppercase
syntax keyword cppSTLios oct
syntax keyword cppSTLios put_money
syntax keyword cppSTLios put_time
syntax keyword cppSTLios resetiosflags
syntax keyword cppSTLios scientific
syntax keyword cppSTLios setbase
syntax keyword cppSTLios setfill
syntax keyword cppSTLios setiosflags
syntax keyword cppSTLios setprecision
syntax keyword cppSTLios setw
syntax keyword cppSTLios showbase
syntax keyword cppSTLios showpoint
syntax keyword cppSTLios showpos
syntax keyword cppSTLios skipws
syntax keyword cppSTLios unitbuf
syntax keyword cppSTLios uppercase
"syntax keyword cppSTLios ws

syntax keyword cppSTLiterator back_insert_iterator
syntax keyword cppSTLiterator const_iterator
syntax keyword cppSTLiterator const_reverse_iterator
syntax keyword cppSTLiterator front_insert_iterator
syntax keyword cppSTLiterator insert_iterator
syntax keyword cppSTLiterator istreambuf_iterator
syntax keyword cppSTLiterator istream_iterator
syntax keyword cppSTLiterator ostreambuf_iterator
syntax keyword cppSTLiterator ostream_iterator

syntax keyword cppSTLiterator iterator
syntax keyword cppSTLiterator output_iterator
syntax keyword cppSTLiterator raw_storage_iterator
syntax keyword cppSTLiterator reverse_iterator

syntax keyword cppSTLiterator_tag bidirectional_iterator_tag
syntax keyword cppSTLiterator_tag forward_iterator_tag
syntax keyword cppSTLiterator_tag input_iterator_tag
syntax keyword cppSTLiterator_tag output_iterator_tag
syntax keyword cppSTLiterator_tag random_access_iterator_tag

syntax keyword cppSTLnamespace rel_ops
syntax keyword cppSTLnamespace std
syntax keyword cppSTLnamespace experimental
syntax keyword cppType allocator
syntax keyword cppType auto_ptr
syntax keyword cppType basic_filebuf
syntax keyword cppType basic_fstream
syntax keyword cppType basic_ifstream
syntax keyword cppType basic_iostream
syntax keyword cppType basic_istream
syntax keyword cppType basic_istringstream
syntax keyword cppType basic_ofstream
syntax keyword cppType basic_ostream
syntax keyword cppType basic_ostringstream
syntax keyword cppType basic_streambuf
syntax keyword cppType basic_string
syntax keyword cppType basic_stringbuf
syntax keyword cppType basic_stringstream
syntax keyword cppType binary_compose
syntax keyword cppType binder1st
syntax keyword cppType binder2nd
syntax keyword cppType bitset
syntax keyword cppType char_traits
syntax keyword cppType char_type
syntax keyword cppType const_mem_fun1_t
syntax keyword cppType const_mem_fun_ref1_t
syntax keyword cppType const_mem_fun_ref_t
syntax keyword cppType const_mem_fun_t
syntax keyword cppType const_pointer
syntax keyword cppType const_reference
syntax keyword cppType container_type
syntax keyword cppType deque
syntax keyword cppType difference_type
syntax keyword cppType div_t
syntax keyword cppType double_t
syntax keyword cppType filebuf
syntax keyword cppType first_type
syntax keyword cppType float_denorm_style
syntax keyword cppType float_round_style
syntax keyword cppType float_t
syntax keyword cppType fstream
syntax keyword cppType gslice_array
syntax keyword cppType ifstream
syntax keyword cppType imaxdiv_t
syntax keyword cppType indirect_array
syntax keyword cppType int_type
syntax keyword cppType ios_base
syntax keyword cppType iostream
syntax keyword cppType istream
syntax keyword cppType istringstream
syntax keyword cppType istrstream
syntax keyword cppType iterator_traits
syntax keyword cppType key_compare
syntax keyword cppType key_type
syntax keyword cppType ldiv_t
syntax keyword cppType list
syntax keyword cppType lldiv_t
syntax keyword cppType map
syntax keyword cppType mapped_type
syntax keyword cppType mask_array
syntax keyword cppType mem_fun1_t
syntax keyword cppType mem_fun_ref1_t
syntax keyword cppType mem_fun_ref_t
syntax keyword cppType mem_fun_t
syntax keyword cppType multimap
syntax keyword cppType multiset
syntax keyword cppType nothrow_t
syntax keyword cppType off_type
syntax keyword cppType ofstream
syntax keyword cppType ostream
syntax keyword cppType ostringstream
syntax keyword cppType ostrstream
syntax keyword cppType pair
syntax keyword cppType pointer
syntax keyword cppType pointer_to_binary_function
syntax keyword cppType pointer_to_unary_function
syntax keyword cppType pos_type
syntax keyword cppType priority_queue
syntax keyword cppType queue
syntax keyword cppType reference
syntax keyword cppType second_type
syntax keyword cppType sequence_buffer
syntax keyword cppType set
syntax keyword cppType sig_atomic_t
syntax keyword cppType size_type
syntax keyword cppType slice_array
syntax keyword cppType stack
syntax keyword cppType stream
syntax keyword cppType streambuf
syntax keyword cppType streamsize
syntax keyword cppType string
syntax keyword cppType stringbuf
syntax keyword cppType stringstream
syntax keyword cppType strstream
syntax keyword cppType strstreambuf
syntax keyword cppType temporary_buffer
syntax keyword cppType test_type

syntax keyword cppType tm
syntax keyword cppType traits_type
syntax keyword cppType type_info
syntax keyword cppType u16string
syntax keyword cppType u32string
syntax keyword cppType unary_compose
syntax keyword cppType unary_negate
syntax keyword cppType valarray
syntax keyword cppType value_compare
syntax keyword cppType value_type
syntax keyword cppType vector
syntax keyword cppType wfilebuf
syntax keyword cppType wfstream
syntax keyword cppType wifstream
syntax keyword cppType wiostream
syntax keyword cppType wistream
syntax keyword cppType wistringstream
syntax keyword cppType wofstream
syntax keyword cppType wostream
syntax keyword cppType wostringstream
syntax keyword cppType wstreambuf
syntax keyword cppType wstring
syntax keyword cppType wstringbuf
syntax keyword cppType wstringstream
syntax keyword cppType numeric_limits

syntax keyword cppSTLfunction mblen
syntax keyword cppSTLfunction mbtowc
syntax keyword cppSTLfunction wctomb
syntax keyword cppSTLfunction mbstowcs
syntax keyword cppSTLfunction wcstombs
syntax keyword cppSTLfunction mbsinit
syntax keyword cppSTLfunction btowc
syntax keyword cppSTLfunction wctob
syntax keyword cppSTLfunction mbrlen
syntax keyword cppSTLfunction mbrtowc
syntax keyword cppSTLfunction wcrtomb
syntax keyword cppSTLfunction mbsrtowcs
syntax keyword cppSTLfunction wcsrtombs

syntax keyword cppConstant MB_LEN_MAX
syntax keyword cppConstant MB_CUR_MAX
syntax keyword cppConstant __STDC_UTF_16__
syntax keyword cppConstant __STDC_UTF_32__

syntax keyword cppSTLfunction iswalnum
syntax keyword cppSTLfunction iswalpha
syntax keyword cppSTLfunction iswlower
syntax keyword cppSTLfunction iswupper
syntax keyword cppSTLfunction iswdigit
syntax keyword cppSTLfunction iswxdigit
syntax keyword cppSTLfunction iswcntrl
syntax keyword cppSTLfunction iswgraph
syntax keyword cppSTLfunction iswspace
syntax keyword cppSTLfunction iswprint
syntax keyword cppSTLfunction iswpunct
syntax keyword cppSTLfunction iswctype
syntax keyword cppSTLfunction wctype

syntax keyword cppSTLfunction towlower
syntax keyword cppSTLfunction towupper
syntax keyword cppSTLfunction towctrans
syntax keyword cppSTLfunction wctrans

syntax keyword cppSTLfunction wcstol
syntax keyword cppSTLfunction wcstoll
syntax keyword cppSTLfunction wcstoul
syntax keyword cppSTLfunction wcstoull
syntax keyword cppSTLfunction wcstof
syntax keyword cppSTLfunction wcstod
syntax keyword cppSTLfunction wcstold

syntax keyword cppSTLfunction wcscpy
syntax keyword cppSTLfunction wcsncpy
syntax keyword cppSTLfunction wcscat
syntax keyword cppSTLfunction wcsncat
syntax keyword cppSTLfunction wcsxfrm
syntax keyword cppSTLfunction wcslen
syntax keyword cppSTLfunction wcscmp
syntax keyword cppSTLfunction wcsncmp
syntax keyword cppSTLfunction wcscoll
syntax keyword cppSTLfunction wcschr
syntax keyword cppSTLfunction wcsrchr
syntax keyword cppSTLfunction wcsspn
syntax keyword cppSTLfunction wcscspn
syntax keyword cppSTLfunction wcspbrk
syntax keyword cppSTLfunction wcsstr
syntax keyword cppSTLfunction wcstok
syntax keyword cppSTLfunction wmemcpy
syntax keyword cppSTLfunction wmemmove
syntax keyword cppSTLfunction wmemcmp
syntax keyword cppSTLfunction wmemchr
syntax keyword cppSTLfunction wmemset

syntax keyword cppConstant WEOF
syntax keyword cppConstant WCHAR_MIN
syntax keyword cppConstant WCHAR_MAX

" localizations library
syntax keyword cppType locale
syntax keyword cppType ctype_base
syntax keyword cppType codecvt_base
syntax keyword cppType messages_base
syntax keyword cppType time_base
syntax keyword cppType money_base
syntax keyword cppType ctype
syntax keyword cppType codecvt
syntax keyword cppType collate
syntax keyword cppType messages
syntax keyword cppType time_get
syntax keyword cppType time_put
syntax keyword cppType num_get
syntax keyword cppType num_put
syntax keyword cppType numpunct
syntax keyword cppType money_get
syntax keyword cppType money_put
syntax keyword cppType moneypunct
syntax keyword cppType ctype_byname
syntax keyword cppType codecvt_byname
syntax keyword cppType messages_byname
syntax keyword cppType collate_byname
syntax keyword cppType time_get_byname
syntax keyword cppType time_put_byname
syntax keyword cppType numpunct_byname
syntax keyword cppType moneypunct_byname

syntax keyword cppSTLfunction use_facet
syntax keyword cppSTLfunction has_facet
syntax keyword cppSTLfunction isspace isblank iscntrl isupper islower isalpha
syntax keyword cppSTLfunction isdigit ispunct isxdigit isalnum isprint isgraph
".}}}

" C++ 11 settings ----------------------------------------------------------{{{
if !exists("cpp_no_cpp11")
    syntax keyword cppType max_align_t
    syntax keyword cppType type_index
    syntax keyword cppType initializer_list

    " Container
    syntax keyword cppType array
    syntax keyword cppType tuple
    syntax keyword cppSTLfunction cbegin
    syntax keyword cppSTLfunction cend
    syntax keyword cppSTLfunction crbegin
    syntax keyword cppSTLfunction crend
    syntax keyword cppSTLfunction shrink_to_fit
    syntax keyword cppSTLfunction emplace
    syntax keyword cppSTLfunction emplace_back
    syntax keyword cppSTLfunction emplace_front
    syntax keyword cppSTLfunction emplace_hint

    " algorithm
    syntax keyword cppSTLfunction all_of any_of none_of
    syntax keyword cppSTLfunction find_if_not
    syntax keyword cppSTLfunction copy_if
    syntax keyword cppSTLfunction copy_n

    syntax keyword cppSTLfunction move_backward
    syntax keyword cppSTLfunction shuffle
    syntax keyword cppSTLfunction is_partitioned
    syntax keyword cppSTLfunction partition_copy
    syntax keyword cppSTLfunction partition_point
    syntax keyword cppSTLfunction is_sorted
    syntax keyword cppSTLfunction is_sorted_until

    syntax keyword cppSTLfunction is_heap_until
    syntax keyword cppSTLfunction minmax
    syntax keyword cppSTLfunction minmax_element
    syntax keyword cppSTLfunction is_permutation
    syntax keyword cppSTLfunction itoa

    " atomic
    syntax keyword cppType atomic
    syntax keyword cppSTLfunction is_lock_free
    syntax keyword cppSTLfunction compare_exchange_weak
    syntax keyword cppSTLfunction compare_exchange_strong
    syntax keyword cppSTLfunction fetch_add
    syntax keyword cppSTLfunction fetch_sub
    syntax keyword cppSTLfunction fetch_and
    syntax keyword cppSTLfunction fetch_or
    syntax keyword cppSTLfunction fetch_xor
    syntax keyword cppSTLfunction atomic_is_lock_free
    syntax keyword cppSTLfunction atomic_store
    syntax keyword cppSTLfunction atomic_store_explicit
    syntax keyword cppSTLfunction atomic_load
    syntax keyword cppSTLfunction atomic_load_explicit
    syntax keyword cppSTLfunction atomic_exchange
    syntax keyword cppSTLfunction atomic_exchange_explicit
    syntax keyword cppSTLfunction atomic_compare_exchange_weak
    syntax keyword cppSTLfunction atomic_compare_exchange_weak_explicit
    syntax keyword cppSTLfunction atomic_compare_exchange_strong
    syntax keyword cppSTLfunction atomic_compare_exchange_strong_explicit
    syntax keyword cppSTLfunction atomic_fetch_add
    syntax keyword cppSTLfunction atomic_fetch_add_explicit
    syntax keyword cppSTLfunction atomic_fetch_sub
    syntax keyword cppSTLfunction atomic_fetch_sub_explicit
    syntax keyword cppSTLfunction atomic_fetch_and
    syntax keyword cppSTLfunction atomic_fetch_and_explicit
    syntax keyword cppSTLfunction atomic_fetch_or
    syntax keyword cppSTLfunction atomic_fetch_or_explicit
    syntax keyword cppSTLfunction atomic_fetch_xor
    syntax keyword cppSTLfunction atomic_fetch_xor_explicit

    syntax keyword cppType atomic_flag
    syntax keyword cppSTLfunction atomic_flag_test_and_set
    syntax keyword cppSTLfunction atomic_flag_test_and_set_explicit
    syntax keyword cppSTLfunction atomic_flag_clear
    syntax keyword cppSTLfunction atomic_flag_clear_explicit

    syntax keyword cppType memory_order
    syntax keyword cppConstant memory_order_relaxed
    syntax keyword cppConstant memory_order_consume
    syntax keyword cppConstant memory_order_acquire
    syntax keyword cppConstant memory_order_release
    syntax keyword cppConstant memory_order_acq_rel
    syntax keyword cppConstant memory_order_seq_cst
    syntax keyword cppSTLfunction atomic_init
    syntax keyword cppSTLfunction kill_dependency
    syntax keyword cppSTLfunction atomic_thread_fence
    syntax keyword cppSTLfunction atomic_signal_fence

    " bitset
    syntax keyword cppSTLfunction to_ullong
    syntax keyword cppSTLfunction all

    " cinttypes
    syntax keyword cppSTLfunction strtoimax
    syntax keyword cppSTLfunction strtoumax
    syntax keyword cppSTLfunction wcstoimax
    syntax keyword cppSTLfunction wcstoumax

    " chrono
    syntax keyword cppSTLnamespace chrono
    syntax keyword cppCast duration_cast
    syntax keyword cppCast time_point_cast
    syntax keyword cppType duration
    syntax keyword cppType system_clock
    syntax keyword cppType steady_clock
    syntax keyword cppType high_resolution_clock
    syntax keyword cppType time_point
    syntax keyword cppType nanoseconds
    syntax keyword cppType microseconds
    syntax keyword cppType milliseconds
    syntax keyword cppType seconds
    syntax keyword cppType minutes
    syntax keyword cppType hours
    syntax keyword cppType treat_as_floating_point
    syntax keyword cppType duration_values
    syntax keyword cppSTLfunction time_since_epoch
    syntax keyword cppSTLfunction to_time_t
    syntax keyword cppSTLfunction from_time_t

    " complex
    syntax keyword cppSTLfunction proj

    " condition_variable
    syntax keyword cppType condition_variable
    syntax keyword cppSTLfunction notify_all
    syntax keyword cppSTLfunction notify_one

    " cstdlib
    syntax keyword cppSTLfunction quick_exit
    syntax keyword cppSTLfunction _Exit
    syntax keyword cppSTLfunction at_quick_exit
    syntax keyword cppSTLfunction forward

    " cuchar
    syntax keyword cppSTLfunction mbrtoc16
    syntax keyword cppSTLfunction c16rtomb
    syntax keyword cppSTLfunction mbrtoc32
    syntax keyword cppSTLfunction c32rtomb

    " exception
    syntax keyword cppType exception_ptr
    syntax keyword cppType nested_exception
    syntax keyword cppSTLfunction get_terminate
    syntax keyword cppSTLfunction make_exception_ptr
    syntax keyword cppSTLfunction current_exception
    syntax keyword cppSTLfunction rethrow_exception
    syntax keyword cppSTLfunction throw_with_nested
    syntax keyword cppSTLfunction rethrow_if_nested
    syntax keyword cppSTLfunction rethrow_nested

    " forward_list
    syntax keyword cppType forward_list
    syntax keyword cppSTLfunction before_begin
    syntax keyword cppSTLfunction cbefore_begin
    syntax keyword cppSTLfunction insert_after
    syntax keyword cppSTLfunction emplace_after
    syntax keyword cppSTLfunction erase_after
    syntax keyword cppSTLfunction splice_after

    " function object
    syntax keyword cppExceptions bad_function_call
    syntax keyword cppSTLfunctional function
    syntax keyword cppConstant _1 _2 _3 _4 _5 _6 _7 _8 _9
    syntax keyword cppType is_bind_expression
    syntax keyword cppType is_placeholder
    syntax keyword cppType reference_wrapper
    syntax keyword cppSTLfunction bind
    syntax keyword cppSTLfunction mem_fn
    syntax keyword cppSTLfunction ref cref

    " future
    syntax keyword cppType future
    syntax keyword cppType packaged_task
    syntax keyword cppType promise
    syntax keyword cppType shared_future
    syntax keyword cppSTLenum future_status
    syntax keyword cppSTLenum future_errc
    syntax keyword cppSTLenum launch
    syntax keyword cppSTLexception future_error
    syntax keyword cppSTLfunction get_future
    syntax keyword cppSTLfunction set_value
    syntax keyword cppSTLfunction set_value_at_thread_exit
    syntax keyword cppSTLfunction set_exception
    syntax keyword cppSTLfunction set_exception_at_thread_exit
    syntax keyword cppSTLfunction wait_for
    syntax keyword cppSTLfunction wait_until
    syntax keyword cppSTLfunction future_category
    syntax keyword cppSTLfunction make_error_code
    syntax keyword cppSTLfunction make_error_condition
    syntax keyword cppSTLfunction make_ready_at_thread_exit

    " io
    syntax keyword cppSTLenum io_errc
    syntax keyword cppSTLfunction iostream_category
    syntax keyword cppSTLfunction vscanf vfscanf vsscanf
    syntax keyword cppSTLfunction snprintf vsnprintf
    syntax keyword cppSTLfunction vwscanf vfwscanf vswscanf

    " iterator
    syntax keyword cppSTLiterator move_iterator
    syntax keyword cppSTLfunction make_move_iterator
    syntax keyword cppSTLfunction next prev

    " limits
    syntax keyword cppConstant max_digits10
    syntax keyword cppSTLfunction lowest

    " locale
    syntax keyword cppType wstring_convert
    syntax keyword cppType wbuffer_convert
    syntax keyword cppType codecvt_utf8
    syntax keyword cppType codecvt_utf16
    syntax keyword cppType codecvt_utf8_utf16
    syntax keyword cppType codecvt_mode
    syntax keyword cppSTLfunction isblank
    syntax keyword cppSTLfunction iswblank

    " memory
    syntax keyword cppType unique_ptr
    syntax keyword cppType shared_ptr
    syntax keyword cppType weak_ptr
    syntax keyword cppType owner_less
    syntax keyword cppType enable_shared_from_this
    syntax keyword cppType default_delete
    syntax keyword cppType allocator_traits
    syntax keyword cppType allocator_type
    syntax keyword cppType allocator_arg_t
    syntax keyword cppType uses_allocator
    syntax keyword cppType scoped_allocator_adaptor
    syntax keyword cppType pointer_safety
    syntax keyword cppType pointer_traits
    syntax keyword cppConstant allocator_arg
    syntax keyword cppExceptions bad_weak_ptr
    syntax keyword cppSTLcast static_pointer_cast
    syntax keyword cppSTLcast dynamic_pointer_cast
    syntax keyword cppSTLcast const_pointer_cast
    syntax keyword cppSTLfunction make_shared
    syntax keyword cppSTLfunction declare_reachable
    syntax keyword cppSTLfunction undeclare_reachable
    syntax keyword cppSTLfunction declare_no_pointers
    syntax keyword cppSTLfunction undeclare_no_pointers
    syntax keyword cppSTLfunction get_pointer_safety
    syntax keyword cppSTLfunction addressof
    syntax keyword cppSTLfunction allocate_shared
    syntax keyword cppSTLfunction get_deleter
    syntax keyword cppSTLfunction align

    " new operation
    syntax keyword cppSTLexception bad_array_new_length
    syntax keyword cppSTLfunction get_new_handler

    " numerics, cmath
    syntax keyword cppConstant HUGE_VALF
    syntax keyword cppConstant HUGE_VALL
    syntax keyword cppConstant INFINITY
    syntax keyword cppConstant NAN
    syntax keyword cppConstant math_errhandling
    syntax keyword cppConstant MATH_ERRNO
    syntax keyword cppConstant MATH_ERREXCEPT
    syntax keyword cppConstant FP_NORMAL
    syntax keyword cppConstant FP_SUBNORMAL
    syntax keyword cppConstant FP_ZERO
    syntax keyword cppConstant FP_INFINITY
    syntax keyword cppConstant FP_NAN
    syntax keyword cppConstant FLT_EVAL_METHOD
    syntax keyword cppSTLfunction imaxabs
    syntax keyword cppSTLfunction imaxdiv
    syntax keyword cppSTLfunction remainder
    syntax keyword cppSTLfunction remquo
    syntax keyword cppSTLfunction fma
    syntax keyword cppSTLfunction fmax
    syntax keyword cppSTLfunction fmin
    syntax keyword cppSTLfunction fdim
    syntax keyword cppSTLfunction nan
    syntax keyword cppSTLfunction nanf
    syntax keyword cppSTLfunction nanl
    syntax keyword cppSTLfunction exp2
    syntax keyword cppSTLfunction expm1
    syntax keyword cppSTLfunction log1p
    syntax keyword cppSTLfunction log2
    syntax keyword cppSTLfunction cbrt
    syntax keyword cppSTLfunction hypot
    syntax keyword cppSTLfunction asinh
    syntax keyword cppSTLfunction acosh
    syntax keyword cppSTLfunction atanh
    syntax keyword cppSTLfunction erf
    syntax keyword cppSTLfunction erfc
    syntax keyword cppSTLfunction lgamma
    syntax keyword cppSTLfunction tgamma
    syntax keyword cppSTLfunction trunc
    syntax keyword cppSTLfunction round
    syntax keyword cppSTLfunction lround
    syntax keyword cppSTLfunction llround
    syntax keyword cppSTLfunction nearbyint
    syntax keyword cppSTLfunction rint
    syntax keyword cppSTLfunction lrint
    syntax keyword cppSTLfunction llrint
    syntax keyword cppSTLfunction scalbn
    syntax keyword cppSTLfunction scalbln
    syntax keyword cppSTLfunction ilogb
    syntax keyword cppSTLfunction logb
    syntax keyword cppSTLfunction nextafter
    syntax keyword cppSTLfunction nexttoward
    syntax keyword cppSTLfunction copysign
    syntax keyword cppSTLfunction fpclassify
    syntax keyword cppSTLfunction isfinite
    syntax keyword cppSTLfunction isinf
    syntax keyword cppSTLfunction isnan
    syntax keyword cppSTLfunction isnormal
    syntax keyword cppSTLfunction signbit

    " random
    syntax keyword cppType linear_congruential_engine
    syntax keyword cppType mersenne_twister_engine
    syntax keyword cppType subtract_with_carry_engine
    syntax keyword cppType discard_block_engine
    syntax keyword cppType independent_bits_engine
    syntax keyword cppType shuffle_order_engine
    syntax keyword cppType random_device
    syntax keyword cppType default_random_engine
    syntax keyword cppType minstd_rand0
    syntax keyword cppType minstd_rand
    syntax keyword cppType mt19937
    syntax keyword cppType mt19937_64
    syntax keyword cppType ranlux24_base
    syntax keyword cppType ranlux48_base
    syntax keyword cppType ranlux24
    syntax keyword cppType ranlux48
    syntax keyword cppType knuth_b
    syntax keyword cppType uniform_int_distribution
    syntax keyword cppType uniform_real_distribution
    syntax keyword cppType bernoulli_distribution
    syntax keyword cppType binomial_distribution
    syntax keyword cppType negative_binomial_distribution
    syntax keyword cppType geometric_distribution
    syntax keyword cppType poisson_distribution
    syntax keyword cppType exponential_distribution
    syntax keyword cppType gamma_distribution
    syntax keyword cppType weibull_distribution
    syntax keyword cppType extreme_value_distribution
    syntax keyword cppType normal_distribution
    syntax keyword cppType lognormal_distribution
    syntax keyword cppType chi_squared_distribution
    syntax keyword cppType cauchy_distribution
    syntax keyword cppType fisher_f_distribution
    syntax keyword cppType student_t_distribution
    syntax keyword cppType discrete_distribution
    syntax keyword cppType piecewise_constant_distribution
    syntax keyword cppType piecewise_linear_distribution
    syntax keyword cppType seed_seq
    syntax keyword cppSTLfunction generate_canonical

    " ratio
    syntax keyword cppType ratio
    syntax keyword cppType yocto
    syntax keyword cppType zepto
    syntax keyword cppType atto
    syntax keyword cppType femto
    syntax keyword cppType pico
    syntax keyword cppType nano
    syntax keyword cppType micro
    syntax keyword cppType milli
    syntax keyword cppType centi
    syntax keyword cppType deci
    syntax keyword cppType deca
    syntax keyword cppType hecto
    syntax keyword cppType kilo
    syntax keyword cppType mega
    syntax keyword cppType giga
    syntax keyword cppType tera
    syntax keyword cppType peta
    syntax keyword cppType exa
    syntax keyword cppType zetta
    syntax keyword cppType yotta
    syntax keyword cppType ratio_add
    syntax keyword cppType ratio_subtract
    syntax keyword cppType ratio_multiply
    syntax keyword cppType ratio_divide
    syntax keyword cppType ratio_equal
    syntax keyword cppType ratio_not_equal
    syntax keyword cppType ratio_less
    syntax keyword cppType ratio_less_equal
    syntax keyword cppType ratio_greater
    syntax keyword cppType ratio_greater_equal

   " thread
    syntax keyword cppType thread
    syntax keyword cppSTLnamespace this_thread
    syntax keyword cppSTLfunction yield
    syntax keyword cppSTLfunction get_id
    syntax keyword cppSTLfunction sleep_for
    syntax keyword cppSTLfunction sleep_until

    syntax keyword cppSTLfunction joinable
    syntax keyword cppSTLfunction get_id
    syntax keyword cppSTLfunction native_handle
    syntax keyword cppSTLfunction hardware_concurrency
    syntax keyword cppSTLfunction join
    syntax keyword cppSTLfunction detach

    syntax keyword cppType mutex
    syntax keyword cppType timed_mutex
    syntax keyword cppType recursive_mutex
    syntax keyword cppType recursive_timed_mutex
    syntax keyword cppType lock_guard
    syntax keyword cppType unique_lock
    syntax keyword cppType defer_lock_t
    syntax keyword cppType try_to_lock_t
    syntax keyword cppType adopt_lock_t
    syntax keyword cppType once_flag
    syntax keyword cppType condition_variable
    syntax keyword cppType condition_variable_any
    syntax keyword cppSTLenum cv_status
    syntax keyword cppConstant defer_lock try_to_lock adopt_lock
    syntax keyword cppSTLfunction try_lock lock unlock try_lock_for
    syntax keyword cppSTLfunction call_once
    syntax keyword cppSTLfunction owns_lock
    syntax keyword cppSTLfunction notify_all_at_thread_exit
    syntax keyword cppSTLfunction release
    syntax keyword cppSTLfunction async

    " regex
    syntax keyword cppType regex
    syntax keyword cppType wregex
    syntax keyword cppType basic_regex
    syntax keyword cppType sub_match
    syntax keyword cppType match_results
    syntax keyword cppType regex_iterator
    syntax keyword cppType regex_token_iterator
    syntax keyword cppType regex_error
    syntax keyword cppType regex_traits

    syntax keyword cppSTLfunction regex_match
    syntax keyword cppSTLfunction regex_search
    syntax keyword cppSTLfunction regex_replace

    syntax keyword cppSTLfunction mark_count
    syntax keyword cppSTLfunction getloc
    syntax keyword cppSTLfunction imbue

    syntax keyword cppSTLnamespace regex_constants
    syntax keyword cppType syntax_option_type
    syntax keyword cppType match_flag_type
    syntax keyword cppType error_type

    syntax keyword cppConstant icase
    syntax keyword cppConstant nosubs
    syntax keyword cppConstant optimize
    syntax keyword cppConstant collate
    syntax keyword cppConstant ECMAScript
    syntax keyword cppConstant basic
    syntax keyword cppConstant extended
    syntax keyword cppConstant awk
    syntax keyword cppConstant grep
    syntax keyword cppConstant egrep

    syntax keyword cppConstant match_default
    syntax keyword cppConstant match_not_bol
    syntax keyword cppConstant match_not_eol
    syntax keyword cppConstant match_not_bow
    syntax keyword cppConstant match_not_eow
    syntax keyword cppConstant match_any
    syntax keyword cppConstant match_not_null
    syntax keyword cppConstant match_continuous
    syntax keyword cppConstant match_prev_avail
    syntax keyword cppConstant format_default
    syntax keyword cppConstant format_sed
    syntax keyword cppConstant format_no_copy
    syntax keyword cppConstant format_first_only

    syntax keyword cppConstant error_collate
    syntax keyword cppConstant error_ctype
    syntax keyword cppConstant error_escape
    syntax keyword cppConstant error_backref
    syntax keyword cppConstant error_brack
    syntax keyword cppConstant error_paren
    syntax keyword cppConstant error_brace
    syntax keyword cppConstant error_badbrace
    syntax keyword cppConstant error_range
    syntax keyword cppConstant error_space
    syntax keyword cppConstant error_badrepeat
    syntax keyword cppConstant error_complexity
    syntax keyword cppConstant error_stack

    " string
    syntax keyword cppSTLfunction stoi
    syntax keyword cppSTLfunction stol
    syntax keyword cppSTLfunction stoll
    syntax keyword cppSTLfunction stoul
    syntax keyword cppSTLfunction stoull
    syntax keyword cppSTLfunction stof
    syntax keyword cppSTLfunction stod
    syntax keyword cppSTLfunction stold

    " system_error
    syntax keyword cppSTLenum errc
    syntax keyword cppType system_error
    syntax keyword cppType error_code
    syntax keyword cppType error_condition
    syntax keyword cppType error_category
    syntax keyword cppType is_error_code_enum
    syntax keyword cppType is_error_condition_enum

    " tuple
    syntax keyword cppType tuple
    syntax keyword cppSTLfunction make_tuple
    syntax keyword cppSTLfunction tie
    syntax keyword cppSTLfunction forward_as_tuple
    syntax keyword cppSTLfunction tuple_cat
    syntax keyword cppType tuple_size tuple_element

    " type_traits
    syntax keyword cppType add_const
    syntax keyword cppType add_cv
    syntax keyword cppType add_lvalue_reference
    syntax keyword cppType add_pointer
    syntax keyword cppType add_rvalue_reference
    syntax keyword cppType add_volatile
    syntax keyword cppType aligned_storage
    syntax keyword cppType aligned_union
    syntax keyword cppType alignment_of
    syntax keyword cppType common_type
    syntax keyword cppType conditional
    syntax keyword cppType decay
    syntax keyword cppType enable_if
    syntax keyword cppType extent
    syntax keyword cppType integral_constant
    syntax keyword cppType is_abstract
    syntax keyword cppType is_arithmetic
    syntax keyword cppType is_array
    syntax keyword cppType is_assignable
    syntax keyword cppType is_base_of
    syntax keyword cppType is_class
    syntax keyword cppType is_compound
    syntax keyword cppType is_const
    syntax keyword cppType is_constructible
    syntax keyword cppType is_convertible
    syntax keyword cppType is_copy_assignable
    syntax keyword cppType is_copy_constructible
    syntax keyword cppType is_default_constructible
    syntax keyword cppType is_destructible
    syntax keyword cppType is_empty
    syntax keyword cppType is_enum
    syntax keyword cppType is_floating_point
    syntax keyword cppType is_function
    syntax keyword cppType is_fundamental
    syntax keyword cppType is_integral
    syntax keyword cppType is_literal_type
    syntax keyword cppType is_lvalue_reference
    syntax keyword cppType is_member_function_pointer
    syntax keyword cppType is_member_object_pointer
    syntax keyword cppType is_member_pointer
    syntax keyword cppType is_move_assignable
    syntax keyword cppType is_move_constructible
    syntax keyword cppType is_nothrow_assignable
    syntax keyword cppType is_nothrow_constructible
    syntax keyword cppType is_nothrow_copy_assignable
    syntax keyword cppType is_nothrow_copy_constructible
    syntax keyword cppType is_nothrow_default_constructible
    syntax keyword cppType is_nothrow_move_assignable
    syntax keyword cppType is_nothrow_move_constructible
    syntax keyword cppType is_object
    syntax keyword cppType is_pod
    syntax keyword cppType is_pointer
    syntax keyword cppType is_polymorphic
    syntax keyword cppType is_reference
    syntax keyword cppType is_rvalue_reference
    syntax keyword cppType is_same
    syntax keyword cppType is_scalar
    syntax keyword cppType is_signed
    syntax keyword cppType is_standard_layout
    syntax keyword cppType is_trivial
    syntax keyword cppType is_trivially_assignable
    syntax keyword cppType is_trivially_constructible
    syntax keyword cppType is_trivially_copyable
    syntax keyword cppType is_trivially_copy_assignable
    syntax keyword cppType is_trivially_copy_constructible
    syntax keyword cppType is_trivially_default_constructible
    syntax keyword cppType is_trivially_destructible
    syntax keyword cppType is_trivially_move_assignable
    syntax keyword cppType is_trivially_move_constructible
    syntax keyword cppType is_union
    syntax keyword cppType is_unsigned
    syntax keyword cppType is_void
    syntax keyword cppType is_volatile
    syntax keyword cppType make_signed
    syntax keyword cppType make_unsigned
    syntax keyword cppType rank
    syntax keyword cppType remove_all_extents
    syntax keyword cppType remove_const
    syntax keyword cppType remove_cv
    syntax keyword cppType remove_extent
    syntax keyword cppType remove_pointer
    syntax keyword cppType remove_reference
    syntax keyword cppType remove_volatile
    syntax keyword cppType result_of
    syntax keyword cppType underlying_type
    syntax keyword cppType true_type
    syntax keyword cppType false_type

    " unordered_map, unordered_set, unordered_multimap, unordered_multiset
    syntax keyword cppType unordered_map
    syntax keyword cppType unordered_set
    syntax keyword cppType unordered_multimap
    syntax keyword cppType unordered_multiset
    syntax keyword cppType hash
    syntax keyword cppType hasher
    syntax keyword cppType key_equal
    syntax keyword cppSTLiterator local_iterator
    syntax keyword cppSTLiterator const_local_iterator
    syntax keyword cppSTLfunction bucket_count
    syntax keyword cppSTLfunction max_bucket_count
    syntax keyword cppSTLfunction bucket_size
    syntax keyword cppSTLfunction bucket
    syntax keyword cppSTLfunction load_factor
    syntax keyword cppSTLfunction max_load_factor
    syntax keyword cppSTLfunction rehash
    syntax keyword cppSTLfunction reserve
    syntax keyword cppSTLfunction hash_function
    syntax keyword cppSTLfunction key_eq

    " utility
    syntax keyword cppType piecewise_construct_t
    syntax keyword cppConstant piecewise_construct
    syntax keyword cppSTLfunction declval
    syntax keyword cppSTLfunction move
    syntax keyword cppSTLfunction move_if_noexcept

endif " C++11
".}}}

" C++ 14 settings ----------------------------------------------------------{{{
if !exists("cpp_no_cpp14")
    " chrono
    syntax keyword cppSTLnamespace literals
    syntax keyword cppSTLnamespace chrono_literals

    " iterator
    syntax keyword cppSTLfunction make_reverse_iterator

    " memory
    syntax keyword cppSTLfunction make_unique

    " dynarray
    syntax keyword cppType dynarray

    " utility
    syntax keyword cppType integer_sequence
    syntax keyword cppType index_sequence_for
    syntax keyword cppType make_integer_sequence
    syntax keyword cppType make_index_sequence
    syntax keyword cppSTLfunction exchange

    " shared_mutex
    syntax keyword cppType shared_timed_mutex
    syntax keyword cppType shared_lock
    syntax keyword cppSTLfunction unlock_shared
    syntax keyword cppSTLfunction try_lock_until
    syntax keyword cppSTLfunction try_lock_shared_for
    syntax keyword cppSTLfunction try_lock_shared_until

    " string
    syntax keyword cppSTLnamespace string_literals

    " tuple
    syntax keyword cppType tuple_element_t

    " type_traits
    syntax keyword cppType is_null_pointer
    syntax keyword cppType remove_cv_t
    syntax keyword cppType remove_const_t
    syntax keyword cppType remove_volatile_t
    syntax keyword cppType add_cv_t
    syntax keyword cppType add_const_t
    syntax keyword cppType add_volatile_t
    syntax keyword cppType remove_reference_t
    syntax keyword cppType add_lvalue_reference_t
    syntax keyword cppType add_rvalue_reference_t
    syntax keyword cppType remove_pointer_t
    syntax keyword cppType add_pointer_t
    syntax keyword cppType make_signed_t
    syntax keyword cppType make_unsigned_t
    syntax keyword cppType remove_extent_t
    syntax keyword cppType remove_all_extents_t
    syntax keyword cppType aligned_storage_t
    syntax keyword cppType aligned_union_t
    syntax keyword cppType decay_t
    syntax keyword cppType enable_if_t
    syntax keyword cppType conditional_t
    syntax keyword cppType common_type_t
    syntax keyword cppType underlying_type_t

endif " C++14
".}}}

" C++ 17 settings ----------------------------------------------------------{{{
if !exists("cpp_no_cpp17")
    syntax keyword cppSTLnamespace pmr

    " Algorithm
    syntax keyword cppSTLfunction for_each_n
    syntax keyword cppSTLfunction sample
    syntax keyword cppSTLfunction clamp

    " optional
    syntax keyword cppType optional
    syntax keyword cppSTLfunction value_or
    syntax keyword cppSTLfunction make_optional
    syntax keyword cppExceptions bad_optional_access
    syntax keyword cppType nullopt_t
    syntax keyword cppConstant nullopt

    " any
    syntax keyword cppType any
    syntax keyword cppCast any_cast
    syntax keyword cppExceptions bad_any_cast
    syntax keyword cppSTLfunction make_any

    " array
    syntax keyword cppSTLfunction to_array
    syntax keyword cppSTLfunction make_array

    " atomic
    syntax keyword cppConstant is_always_lock_free

    " chrono
    syntax keyword cppSTLbool treat_as_floating_point_v

    " cmath
    syntax keyword cppSTLfunction assoc_laguerre assoc_laguerref assoc_laguerrel
    syntax keyword cppSTLfunction assoc_legendre assoc_legendref assoc_legendrel
    syntax keyword cppSTLfunction beta betaf betal
    syntax keyword cppSTLfunction comp_ellint_1 comp_ellint_1f comp_ellint_1l
    syntax keyword cppSTLfunction comp_ellint_2 comp_ellint_2f comp_ellint_2l
    syntax keyword cppSTLfunction comp_ellint_3 comp_ellint_3f comp_ellint_3l
    syntax keyword cppSTLfunction cyl_bessel_i cyl_bessel_if cyl_bessel_il
    syntax keyword cppSTLfunction cyl_bessel_j cyl_bessel_jf cyl_bessel_jl
    syntax keyword cppSTLfunction cyl_bessel_k cyl_bessel_kf cyl_bessel_kl
    syntax keyword cppSTLfunction cyl_neumann cyl_neumannf cyl_neumannl
    syntax keyword cppSTLfunction ellint_1 ellint_1f ellint_1l
    syntax keyword cppSTLfunction ellint_2 ellint_2f ellint_2l
    syntax keyword cppSTLfunction ellint_3 ellint_3f ellint_3l
    syntax keyword cppSTLfunction expint expintf expintl
    syntax keyword cppSTLfunction hermite hermitef hermitel
    syntax keyword cppSTLfunction legendre legendrefl egendrel
    syntax keyword cppSTLfunction laguerre laguerref laguerrel
    syntax keyword cppSTLfunction riemann_zeta riemann_zetaf riemann_zetal
    syntax keyword cppSTLfunction sph_bessel sph_besself sph_bessell
    syntax keyword cppSTLfunction sph_legendre sph_legendref sph_legendrel
    syntax keyword cppSTLfunction sph_neumann sph_neumannf sph_neumannl

    " cstdlib
    syntax keyword cppSTLfunction aligned_alloc

    " exception
    syntax keyword cppSTLfunction uncaught_exceptions

    " execution
    syntax keyword cppSTLnamespace execution
    syntax keyword cppConstant seq par par_unseq
    syntax keyword cppSTLbool is_execution_policy_v
    syntax keyword cppType sequenced_policy
    syntax keyword cppType parallel_policy
    syntax keyword cppType parallel_unsequenced_policy
    syntax keyword cppType is_execution_policy

    " filesystem
    syntax keyword cppSTLnamespace filesystem
    syntax keyword cppSTLexception filesystem_error
    syntax keyword cppType path
    syntax keyword cppType directory_entry
    syntax keyword cppType directory_iterator
    syntax keyword cppType recursive_directory_iterator
    syntax keyword cppType file_status
    syntax keyword cppType space_info
    syntax keyword cppType file_time_type
    syntax keyword cppSTLenum file_type
    syntax keyword cppSTLenum perms
    syntax keyword cppSTLenum copy_options
    syntax keyword cppSTLenum directory_options
    syntax keyword cppConstant preferred_separator
    syntax keyword cppConstant available
    " Note: 'capacity' and 'free' are already set as cppSTLfunction
    " syntax keyword cppConstant capacity
    " syntax keyword cppConstant free
    syntax keyword cppSTLfunction concat
    syntax keyword cppSTLfunction make_preferred
    syntax keyword cppSTLfunction remove_filename
    syntax keyword cppSTLfunction replace_filename
    syntax keyword cppSTLfunction replace_extension
    syntax keyword cppSTLfunction native
    syntax keyword cppSTLfunction string_type
    " Note: wstring, u8string, u16string, u32string already set as cppType
    " syntax keyword cppSTLfunction wstring
    " syntax keyword cppSTLfunction u8string
    " syntax keyword cppSTLfunction u16string
    " syntax keyword cppSTLfunction u32string
    syntax keyword cppSTLfunction generic_string
    syntax keyword cppSTLfunction generic_wstring
    syntax keyword cppSTLfunction generic_u8string
    syntax keyword cppSTLfunction generic_u16string
    syntax keyword cppSTLfunction generic_u32string
    syntax keyword cppSTLfunction lexically_normal
    syntax keyword cppSTLfunction lexically_relative
    syntax keyword cppSTLfunction lexically_proximate
    syntax keyword cppSTLfunction root_name
    syntax keyword cppSTLfunction root_directory
    syntax keyword cppSTLfunction root_path
    syntax keyword cppSTLfunction relative_path
    syntax keyword cppSTLfunction parent_path
    " syntax keyword cppSTLfunction filename
    syntax keyword cppSTLfunction stem
    syntax keyword cppSTLfunction extension
    syntax keyword cppSTLfunction has_root_name
    syntax keyword cppSTLfunction has_root_directory
    syntax keyword cppSTLfunction has_root_path
    syntax keyword cppSTLfunction has_relative_path
    syntax keyword cppSTLfunction has_parent_path
    syntax keyword cppSTLfunction has_filename
    syntax keyword cppSTLfunction has_stem
    syntax keyword cppSTLfunction has_extension
    syntax keyword cppSTLfunction is_absolute
    syntax keyword cppSTLfunction is_relative
    syntax keyword cppSTLfunction hash_value
    syntax keyword cppSTLfunction u8path
    syntax keyword cppSTLfunction path1
    syntax keyword cppSTLfunction path2
    " syntax keyword cppSTLfunction path
    syntax keyword cppSTLfunction status
    syntax keyword cppSTLfunction symlink_status
    syntax keyword cppSTLfunction options
    " syntax keyword cppSTLfunction depth
    syntax keyword cppSTLfunction recursive_pending
    syntax keyword cppSTLfunction disable_recursive_pending
    " syntax keyword cppSTLfunction type
    syntax keyword cppSTLfunction permissions
    syntax keyword cppSTLfunction absolute
    syntax keyword cppSTLfunction system_complete
    syntax keyword cppSTLfunction canonical
    syntax keyword cppSTLfunction weakly_canonical
    syntax keyword cppSTLfunction relative
    syntax keyword cppSTLfunction proximate
    syntax keyword cppSTLfunction copy_file
    syntax keyword cppSTLfunction copy_symlink
    syntax keyword cppSTLfunction create_directory
    syntax keyword cppSTLfunction create_directories
    syntax keyword cppSTLfunction create_hard_link
    syntax keyword cppSTLfunction create_symlink
    syntax keyword cppSTLfunction create_directory_symlink
    syntax keyword cppSTLfunction current_path
    " syntax keyword cppSTLfunction exists
    syntax keyword cppSTLfunction file_size
    syntax keyword cppSTLfunction hard_link_count
    syntax keyword cppSTLfunction last_write_time
    syntax keyword cppSTLfunction read_symlink
    syntax keyword cppSTLfunction remove_all
    syntax keyword cppSTLfunction resize_file
    syntax keyword cppSTLfunction space
    syntax keyword cppSTLfunction temp_directory_path
    syntax keyword cppSTLfunction is_block_file
    syntax keyword cppSTLfunction is_character_file
    syntax keyword cppSTLfunction is_directory
    syntax keyword cppSTLfunction is_fifo
    syntax keyword cppSTLfunction is_other
    syntax keyword cppSTLfunction is_regular_file
    syntax keyword cppSTLfunction is_socket
    syntax keyword cppSTLfunction is_symlink
    syntax keyword cppSTLfunction status_known
    " Note: 'is_empty' already set as cppType
    " syntax keyword cppSTLfunction is_empty

    " functional
    syntax keyword cppType default_order
    syntax keyword cppType default_order_t
    syntax keyword cppType default_searcher
    syntax keyword cppType boyer_moore_searcher
    syntax keyword cppType boyer_moore_horspool_searcher
    syntax keyword cppSTLbool is_bind_expression_v
    syntax keyword cppSTLbool is_placeholder_v
    syntax keyword cppSTLfunction not_fn
    syntax keyword cppSTLfunction make_default_searcher
    syntax keyword cppSTLfunction make_boyer_moore_searcher
    syntax keyword cppSTLfunction make_boyer_moore_horspool_searcher
    " syntax keyword cppSTLfunction invoke

    " memory
    syntax keyword cppSTLcast reinterpret_pointer_cast
    syntax keyword cppSTLfunction uninitialized_move
    syntax keyword cppSTLfunction uninitialized_move_n
    syntax keyword cppSTLfunction uninitialized_default_construct
    syntax keyword cppSTLfunction uninitialized_default_construct_n
    syntax keyword cppSTLfunction uninitialized_value_construct
    syntax keyword cppSTLfunction uninitialized_value_construct_n
    syntax keyword cppSTLfunction destroy_at
    syntax keyword cppSTLfunction destroy_n

    " memory_resource
    syntax keyword cppType polymorphic_allocator
    syntax keyword cppType memory_resource
    syntax keyword cppType synchronized_pool_resource
    syntax keyword cppType unsynchronized_pool_resource
    syntax keyword cppType pool_options
    syntax keyword cppType monotonic_buffer_resource
    syntax keyword cppSTLfunction upstream_resource
    syntax keyword cppSTLfunction get_default_resource
    syntax keyword cppSTLfunction new_default_resource
    syntax keyword cppSTLfunction set_default_resource
    syntax keyword cppSTLfunction null_memory_resource
    syntax keyword cppSTLfunction allocate
    syntax keyword cppSTLfunction deallocate
    syntax keyword cppSTLfunction construct
    syntax keyword cppSTLfunction destruct
    syntax keyword cppSTLfunction resource
    syntax keyword cppSTLfunction select_on_container_copy_construction
    syntax keyword cppSTLfunction do_allocate
    syntax keyword cppSTLfunction do_deallocate
    syntax keyword cppSTLfunction do_is_equal

    " mutex
    syntax keyword cppType scoped_lock

    " new
    syntax keyword cppConstant hardware_destructive_interference_size
    syntax keyword cppConstant hardware_constructive_interference_size
    syntax keyword cppSTLfunction launder

    " numeric
    syntax keyword cppSTLfunction gcd
    syntax keyword cppSTLfunction lcm
    syntax keyword cppSTLfunction exclusive_scan
    syntax keyword cppSTLfunction inclusive_scan
    syntax keyword cppSTLfunction transform_reduce
    syntax keyword cppSTLfunction transform_exclusive_scan
    syntax keyword cppSTLfunction transform_inclusive_scan
    " syntax keyword cppSTLfunction reduce

    " optional
    syntax keyword cppType optional
    syntax keyword cppType nullopt_t
    syntax keyword cppSTLexception bad_optional_access
    syntax keyword cppConstant nullopt
    syntax keyword cppSTLfunction make_optional
    syntax keyword cppSTLfunction value_or
    syntax keyword cppSTLfunction has_value
    " syntax keyword cppSTLfunction value

    " string_view
    syntax keyword cppSTLnamespace string_view_literals
    syntax keyword cppType basic_string_view
    syntax keyword cppType string_view
    syntax keyword cppType u8string_view
    syntax keyword cppType u16string_view
    syntax keyword cppType u32string_view
    syntax keyword cppType wstring_view
    syntax keyword cppSTLfunction remove_prefix
    syntax keyword cppSTLfunction remove_suffix
    syntax keyword cppSTLfunction starts_with
    syntax keyword cppSTLfunction ends_with

    " system_error
    syntax keyword cppSTLbool is_error_code_enum_v
    syntax keyword cppSTLbool is_error_condition_enum_v

    " thread
    syntax keyword cppType shared_mutex
    syntax keyword cppType lock_shared, try_lock_shared
    syntax keyword cppType scoped_lock

    " tuple
    syntax keyword cppSTLfunction make_from_tuple
    syntax keyword cppSTLfunction apply

    " type_traits
    syntax keyword cppConstant alignment_of_v
    syntax keyword cppConstant extent_v
    syntax keyword cppConstant is_abstract_v
    syntax keyword cppConstant is_arithmetic_v
    syntax keyword cppConstant is_array_v
    syntax keyword cppConstant is_assignable_v
    syntax keyword cppConstant is_base_of_v
    syntax keyword cppConstant is_class_v
    syntax keyword cppConstant is_compound_v
    syntax keyword cppConstant is_const_v
    syntax keyword cppConstant is_constructible_v
    syntax keyword cppConstant is_convertible_v
    syntax keyword cppConstant is_copy_assignable_v
    syntax keyword cppConstant is_copy_constructible_v
    syntax keyword cppConstant is_default_constructible_v
    syntax keyword cppConstant is_destructible_v
    syntax keyword cppConstant is_empty_v
    syntax keyword cppConstant is_enum_v
    syntax keyword cppConstant is_floating_point_v
    syntax keyword cppConstant is_function_v
    syntax keyword cppConstant is_fundamental_v
    syntax keyword cppConstant is_integral_v
    syntax keyword cppConstant is_literal_type_v
    syntax keyword cppConstant is_lvalue_reference_v
    syntax keyword cppConstant is_member_function_pointer_v
    syntax keyword cppConstant is_member_object_pointer_v
    syntax keyword cppConstant is_member_pointer_v
    syntax keyword cppConstant is_move_assignable_v
    syntax keyword cppConstant is_move_constructible_v
    syntax keyword cppConstant is_nothrow_assignable_v
    syntax keyword cppConstant is_nothrow_constructible_v
    syntax keyword cppConstant is_nothrow_copy_assignable_v
    syntax keyword cppConstant is_nothrow_copy_constructible_v
    syntax keyword cppConstant is_nothrow_default_constructible_v
    syntax keyword cppConstant is_nothrow_move_assignable_v
    syntax keyword cppConstant is_nothrow_move_constructible_v
    syntax keyword cppConstant is_object_v
    syntax keyword cppConstant is_pod_v
    syntax keyword cppConstant is_pointer_v
    syntax keyword cppConstant is_polymorphic_v
    syntax keyword cppConstant is_reference_v
    syntax keyword cppConstant is_rvalue_reference_v
    syntax keyword cppConstant is_same_v
    syntax keyword cppConstant is_scalar_v
    syntax keyword cppConstant is_signed_v
    syntax keyword cppConstant is_standard_layout_v
    syntax keyword cppConstant is_trivial_v
    syntax keyword cppConstant is_trivially_assignable_v
    syntax keyword cppConstant is_trivially_constructible_v
    syntax keyword cppConstant is_trivially_copyable_v
    syntax keyword cppConstant is_trivially_copy_assignable_v
    syntax keyword cppConstant is_trivially_copy_constructible_v
    syntax keyword cppConstant is_trivially_default_constructible_v
    syntax keyword cppConstant is_trivially_destructible_v
    syntax keyword cppConstant is_trivially_move_assignable_v
    syntax keyword cppConstant is_trivially_move_constructible_v
    syntax keyword cppConstant is_union_v
    syntax keyword cppConstant is_unsigned_v
    syntax keyword cppConstant is_void_v
    syntax keyword cppConstant is_volatile_v
    syntax keyword cppConstant rank_v
    syntax keyword cppConstant is_null_pointer_v
    syntax keyword cppConstant has_unique_object_representations_v
    syntax keyword cppConstant has_strong_structural_equality_v
    syntax keyword cppConstant is_final_v
    syntax keyword cppConstant is_aggregate_v
    syntax keyword cppConstant is_bounded_array_v
    syntax keyword cppConstant is_unbounded_array_v
    syntax keyword cppConstant is_swappable_with_v
    syntax keyword cppConstant is_swappable_v
    syntax keyword cppConstant is_nothrow_swappable_with_v
    syntax keyword cppConstant is_nothrow_swappable_v
    syntax keyword cppConstant is_layout_compatible_v
    syntax keyword cppConstant is_invocable_v
    syntax keyword cppConstant is_invocable_r_v
    syntax keyword cppConstant is_nothrow_invocable_v
    syntax keyword cppConstant is_nothrow_invocable_r_v
    syntax keyword cppType bool_constant
    syntax keyword cppType has_unique_object_representations
    syntax keyword cppType is_final
    syntax keyword cppType has_strong_structural_equality
    syntax keyword cppType is_aggregate
    syntax keyword cppType is_bounded_array
    syntax keyword cppType is_unbounded_array
    syntax keyword cppType is_swappable_with
    syntax keyword cppType is_swappable
    syntax keyword cppType is_nothrow_swappable_with
    syntax keyword cppType is_nothrow_swappable
    syntax keyword cppType is_layout_compatible
    syntax keyword cppType is_invocable
    syntax keyword cppType is_invocable_r
    syntax keyword cppType is_nothrow_invocable
    syntax keyword cppType is_nothrow_invocable_r
    syntax keyword cppType invoke_result
    syntax keyword cppType invoke_result_t
    syntax keyword cppType void_t

    " unordered_map, unordered_set, unordered_multimap, unordered_multiset
    syntax keyword cppType node_type
    syntax keyword cppType insert_return_type
    syntax keyword cppSTLfunction try_emplace
    syntax keyword cppSTLfunction insert_or_assign
    syntax keyword cppSTLfunction extract

    " utility
    syntax keyword cppType in_place_tag
    syntax keyword cppType in_place_t
    syntax keyword cppType in_place_type_t
    syntax keyword cppType in_place_index_t
    syntax keyword cppConstant in_place
    syntax keyword cppConstant in_place_type
    syntax keyword cppConstant in_place_index
    syntax keyword cppSTLfunction as_const

    " variant
    syntax keyword cppType variant
    syntax keyword cppType monostate
    syntax keyword cppType variant_size
    syntax keyword cppType variant_alternative
    syntax keyword cppConstant variant_alternative_t
    syntax keyword cppConstant variant_size_v
    syntax keyword cppConstant variant_npos
    syntax keyword cppExceptions bad_variant_access
    syntax keyword cppSTLfunction valueless_by_exception
    syntax keyword cppSTLfunction holds_alternative
    syntax keyword cppSTLfunction get_if
    syntax keyword cppSTLfunction visit

endif " C++17
".}}}

" C++ 20 settings ----------------------------------------------------------{{{
if !exists("cpp_no_cpp20")
    syntax keyword cppType char8_t
    syntax keyword cppStatement co_yield co_return co_await
    syntax keyword cppStorageClass consteval
    syntax keyword cppSTLnamespace ranges

    " algorithm
    syntax keyword cppSTLfunction shift_left
    syntax keyword cppSTLfunction shift_right
    syntax keyword cppSTLfunction lexicographical_compare_three_way

    " bit
    syntax keyword cppSTLcast bit_cast
    syntax keyword cppSTLfunction ispow2
    syntax keyword cppSTLfunction ceil2
    syntax keyword cppSTLfunction floor2
    syntax keyword cppSTLfunction log2p1
    syntax keyword cppSTLfunction rotl
    syntax keyword cppSTLfunction rotr
    syntax keyword cppSTLfunction countl_zero
    syntax keyword cppSTLfunction countl_one
    syntax keyword cppSTLfunction countr_zero
    syntax keyword cppSTLfunction countr_one
    syntax keyword cppSTLfunction popcount
    syntax keyword cppType endian

    " compare
    syntax keyword cppType weak_equality
    syntax keyword cppType strong_equality
    syntax keyword cppType partial_ordering
    syntax keyword cppType weak_ordering
    syntax keyword cppType strong_ordering
    syntax keyword cppType common_comparison_category
    syntax keyword cppType compare_three_way_result
    syntax keyword cppType compare_three_way
    syntax keyword cppType strong_order
    syntax keyword cppType weak_order
    syntax keyword cppType parital_order
    syntax keyword cppType compare_strong_order_fallback
    syntax keyword cppType compare_weak_order_fallback
    syntax keyword cppType compare_parital_order_fallback
    syntax keyword cppSTLfunction is_eq
    syntax keyword cppSTLfunction is_neq
    syntax keyword cppSTLfunction is_lt
    syntax keyword cppSTLfunction is_lteq
    syntax keyword cppSTLfunction is_gt
    syntax keyword cppSTLfunction is_gteq

    " format
    syntax keyword cppType formatter
    syntax keyword cppType basic_format_parse_context
    syntax keyword cppType format_parse_context
    syntax keyword cppType wformat_parse_context
    syntax keyword cppType basic_format_context
    syntax keyword cppType format_context
    syntax keyword cppType wformat_context
    syntax keyword cppType basic_format_arg
    syntax keyword cppType basic_format_args
    syntax keyword cppType format_args
    syntax keyword cppType wformat_args
    syntax keyword cppType format_args_t
    syntax keyword cppType format_error
    syntax keyword cppSTLfuntion format
    syntax keyword cppSTLfuntion format_to
    syntax keyword cppSTLfuntion format_to_n
    syntax keyword cppSTLfuntion formatted_size
    syntax keyword cppSTLfuntion vformat
    syntax keyword cppSTLfuntion vformat_to
    syntax keyword cppSTLfuntion visit_format_arg
    syntax keyword cppSTLfuntion make_format_args
    syntax keyword cppSTLfuntion make_wformat_args

    " iterator
    syntax keyword cppType default_sentinel_t unreachable_sentinel_t
    syntax keyword cppSTLiterator common_iterator
    syntax keyword cppSTLiterator counted_iterator
    syntax keyword cppSTLiterator_tag contiguous_iterator_tag

    " memory
    syntax keyword cppSTLfunction to_address
    syntax keyword cppSTLfunction assume_aligned
    syntax keyword cppSTLfunction make_unique_default_init
    syntax keyword cppSTLfunction allocate_shared_default_init

    " source_location
    syntax keyword cppType source_location

    " span
    syntax keyword cppType span
    syntax keyword cppSTLfunction as_bytes
    syntax keyword cppSTLfunction as_writable_bytes
    syntax keyword cppConstant dynamic_extent

    " syncstream
    syntax keyword cppType basic_syncbuf
    syntax keyword cppType basic_osyncstream
    syntax keyword cppType syncbuf
    syntax keyword cppType wsyncbuf
    syntax keyword cppType osyncstream
    syntax keyword cppType wosyncstream

    " type_traits
    syntax keyword cppType remove_cvref remove_cvref_t
    syntax keyword cppType common_reference common_reference_t
    syntax keyword cppSTLfunction is_constant_evaluated
    syntax keyword cppSTLfunction is_pointer_interconvertible
    syntax keyword cppSTLfunction is_corresponding_member
    syntax keyword cppType is_nothrow_convertible
    syntax keyword cppSTLbool is_nothrow_convertible_v
    syntax keyword cppType is_layout_compatible
    syntax keyword cppSTLbool is_layout_compatible_v
    syntax keyword cppType is_bounded_array
    syntax keyword cppConstant is_bounded_array_v
    syntax keyword cppType is_unbounded_array
    syntax keyword cppSTLbool is_unbounded_array_v
    syntax keyword cppType is_pointer_interconvertible_base_of
    syntax keyword cppSTLbool is_pointer_interconvertible_base_of_v
    syntax keyword cppType has_strong_structural_equality
    syntax keyword cppConstant has_strong_structural_equality_v

    " version
    " TODO
endif " C++ 20
".}}}

" C++ concepts settings ----------------------------------------------------{{{
if exists('g:cpp_concepts_highlight')
    syntax keyword cppStatement concept
    syntax keyword cppStorageClass requires

    if g:cpp_concepts_highlight == 1
        syntax keyword cppSTLconcept DefaultConstructible
        syntax keyword cppSTLconcept MoveConstructible
        syntax keyword cppSTLconcept CopyConstructible
        syntax keyword cppSTLconcept MoveAssignable
        syntax keyword cppSTLconcept CopyAssignable
        syntax keyword cppSTLconcept Destructible
        syntax keyword cppSTLconcept TriviallyCopyable
        syntax keyword cppSTLconcept TrivialType
        syntax keyword cppSTLconcept StandardLayoutType
        syntax keyword cppSTLconcept PODType
        syntax keyword cppSTLconcept EqualityComparable
        syntax keyword cppSTLconcept LessThanComparable
        syntax keyword cppSTLconcept Swappable
        syntax keyword cppSTLconcept ValueSwappable
        syntax keyword cppSTLconcept NullablePointer
        syntax keyword cppSTLconcept Hash
        syntax keyword cppSTLconcept Allocator
        syntax keyword cppSTLconcept FunctionObject
        syntax keyword cppSTLconcept Callable
        syntax keyword cppSTLconcept Predicate
        syntax keyword cppSTLconcept BinaryPredicate
        syntax keyword cppSTLconcept Compare
        syntax keyword cppSTLconcept Container
        syntax keyword cppSTLconcept ReversibleContainer
        syntax keyword cppSTLconcept AllocatorAwareContainer
        syntax keyword cppSTLconcept SequenceContainer
        syntax keyword cppSTLconcept ContiguousContainer
        syntax keyword cppSTLconcept AssociativeContainer
        syntax keyword cppSTLconcept UnorderedAssociativeContainer
        syntax keyword cppSTLconcept DefaultInsertable
        syntax keyword cppSTLconcept CopyInsertable
        syntax keyword cppSTLconcept CopyInsertable
        syntax keyword cppSTLconcept MoveInsertable
        syntax keyword cppSTLconcept EmplaceConstructible
        syntax keyword cppSTLconcept Erasable
        syntax keyword cppSTLconcept Iterator
        syntax keyword cppSTLconcept InputIterator
        syntax keyword cppSTLconcept OutputIterator
        syntax keyword cppSTLconcept ForwardIterator
        syntax keyword cppSTLconcept BidirectionalIterator
        syntax keyword cppSTLconcept RandomAccessIterator
        syntax keyword cppSTLconcept ContiguousIterator
        syntax keyword cppSTLconcept UnformattedInputFunction
        syntax keyword cppSTLconcept FormattedInputFunction
        syntax keyword cppSTLconcept UnformattedOutputFunction
        syntax keyword cppSTLconcept FormattedOutputFunction
        syntax keyword cppSTLconcept SeedSequence
        syntax keyword cppSTLconcept UniformRandomBitGenerator
        syntax keyword cppSTLconcept RandomNumberEngine
        syntax keyword cppSTLconcept RandomNumberEngineAdaptor
        syntax keyword cppSTLconcept RandomNumberDistribution
        syntax keyword cppSTLconcept BasicLockable
        syntax keyword cppSTLconcept Lockable
        syntax keyword cppSTLconcept TimedLockable
        syntax keyword cppSTLconcept Mutex
        syntax keyword cppSTLconcept TimedMutex
        syntax keyword cppSTLconcept SharedMutex
        syntax keyword cppSTLconcept SharedTimedMutex
        syntax keyword cppSTLconcept UnaryTypeTrait
        syntax keyword cppSTLconcept BinaryTypeTrait
        syntax keyword cppSTLconcept TransformationTrait
        syntax keyword cppSTLconcept Clock
        syntax keyword cppSTLconcept TrivialClock
        syntax keyword cppSTLconcept CharTraits
        syntax keyword cppSTLconcept pos_type
        syntax keyword cppSTLconcept off_type
        syntax keyword cppSTLconcept BitmaskType
        syntax keyword cppSTLconcept NumericType
        syntax keyword cppSTLconcept RegexTraits
        syntax keyword cppSTLconcept LiteralType
  elseif g:cpp_concepts_highlight == 2
        syntax keyword cppSTLconcept same_as
        syntax keyword cppSTLconcept derived_from
        syntax keyword cppSTLconcept convertible_to
        syntax keyword cppSTLconcept common_reference_with
        syntax keyword cppSTLconcept common_with
        syntax keyword cppSTLconcept integral
        syntax keyword cppSTLconcept signed_integral
        syntax keyword cppSTLconcept unsigned_integral
        syntax keyword cppSTLconcept assignable_from
        syntax keyword cppSTLconcept swappable
        syntax keyword cppSTLconcept swappable_with
        syntax keyword cppSTLconcept destructible
        syntax keyword cppSTLconcept constructible_from
        syntax keyword cppSTLconcept default_constructible
        syntax keyword cppSTLconcept move_constructible
        syntax keyword cppSTLconcept copy_constructible
        syntax keyword cppSTLconcept boolean
        syntax keyword cppSTLconcept equality_comparable
        syntax keyword cppSTLconcept equality_comparable_with
        syntax keyword cppSTLconcept totally_ordered
        syntax keyword cppSTLconcept totally_ordered_with
        syntax keyword cppSTLconcept movable
        syntax keyword cppSTLconcept copyable
        syntax keyword cppSTLconcept semiregular
        syntax keyword cppSTLconcept regular
        syntax keyword cppSTLconcept invocable
        syntax keyword cppSTLconcept regular_invocable
        syntax keyword cppSTLconcept predicate
        syntax keyword cppSTLconcept relation
        syntax keyword cppSTLconcept strict_weak_order
        syntax keyword cppSTLconcept readable
        syntax keyword cppSTLconcept writable
        syntax keyword cppSTLconcept weakly_incrementable
        syntax keyword cppSTLconcept incrementable
        syntax keyword cppSTLconcept input_or_output_iterator
        syntax keyword cppSTLconcept sentinal_for
        syntax keyword cppSTLconcept sized_sentinal_for
        syntax keyword cppSTLconcept input_iterator
        syntax keyword cppSTLconcept output_iterator
        syntax keyword cppSTLconcept forward_iterator
        syntax keyword cppSTLconcept bidirectional_iterator
        syntax keyword cppSTLconcept random_access_iterator
        syntax keyword cppSTLconcept input_iterator
        syntax keyword cppSTLconcept output_iterator
        syntax keyword cppSTLconcept bidirectional_iterator
        syntax keyword cppSTLconcept random_access_iterator
        syntax keyword cppSTLconcept contiguous_iterator
        syntax keyword cppSTLconcept indirectly_unary_invocable
        syntax keyword cppSTLconcept indirectly_regular_unary_invocable
        syntax keyword cppSTLconcept indirect_unary_predicate
        syntax keyword cppSTLconcept indirect_relation
        syntax keyword cppSTLconcept indirect_strict_weak_order
        syntax keyword cppSTLconcept indirectly_movable
        syntax keyword cppSTLconcept indirectly_movable_storable
        syntax keyword cppSTLconcept indirectly_copyable
        syntax keyword cppSTLconcept indirectly_copyable_storable
        syntax keyword cppSTLconcept indirectly_swappable
        syntax keyword cppSTLconcept indirectly_comparable
        syntax keyword cppSTLconcept permutable
        syntax keyword cppSTLconcept mergeable
        syntax keyword cppSTLconcept sortable
        syntax keyword cppSTLconcept range
        syntax keyword cppSTLconcept sized_range
        syntax keyword cppSTLconcept output_range
        syntax keyword cppSTLconcept input_range
        syntax keyword cppSTLconcept bidirectional_range
        syntax keyword cppSTLconcept random_access_range
        syntax keyword cppSTLconcept contiguous_range
        syntax keyword cppSTLconcept common_range
        syntax keyword cppSTLconcept viewable_range
        syntax keyword cppSTLconcept uniform_random_bit_generator
  endif
endif " C++ concepts
".}}}

" C++ boost settings -------------------------------------------------------{{{
if !exists("cpp_no_boost")
    syntax keyword cppSTLnamespace boost
    syntax keyword cppSTLcast lexical_cast
endif " boost
".}}}

" Default highlighting -----------------------------------------------------{{{
if version >= 508 || !exists("did_cpp_syntax_inits")
  if version < 508
    let did_cpp_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  HiLink cppSTLbool         cppBoolean
  HiLink cppStorageClass    cppStorageClass
  HiLink cppSTLfunction     cFunction
  HiLink cppSTLfunctional   cppTypedef
  HiLink cppSTLnamespace    cppNamespace
  HiLink cppType            cppTypedef
  HiLink cppSTLexception    cppSTLExceptions
  HiLink cppSTLiterator     cppTypedef
  HiLink cppSTLiterator_tag cppTypedef
  HiLink cppSTLenum         cppTypedef
  HiLink cppSTLconcept      cppTypedef
  HiLink cppSTLios          cFunction
  HiLink cppSTLcast         cppStatement
  HiLink cppRawString       String
  HiLink cppRawDelimiter    Delimiter
  delcommand HiLink
endif
".}}}

" vim: set fdl=0 fdm=marker:
