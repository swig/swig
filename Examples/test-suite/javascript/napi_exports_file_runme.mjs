import { global_fn, global_var, global_class, global_ns } from '%target/napi_exports_file_wrap.cjs';

if (typeof global_fn !== 'function') throw new Error('global_fn not found');
if (typeof global_var !== 'number') throw new Error('global_var not found');
if (typeof global_class !== 'function') throw new Error('global_class not found');
if (typeof global_ns !== 'object') throw new Error('global_ns not found');
if (typeof global_ns.hidden !== 'number') throw new Error('global_ns.hidden not found');
