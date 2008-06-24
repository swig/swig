/**
 * @file   std_queue.i
 * @author gga
 * @date   Sun May  6 01:52:44 2007
 * 
 * @brief  test of std::queue
 * 
 * 
 */

%module li_std_queue

%include std_queue.i


%template( IntQueue ) std::queue< int >;
