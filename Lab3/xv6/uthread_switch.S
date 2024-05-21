	.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
	
	subl $0x4, %esp
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	pushl %esi
	pushl %edi
	pushl %ebp
	
	movl current_thread, %eax
	movl %esp, (%eax)
	
	movl next_thread, %eax
	movl (%eax), %esp

	movl %eax, current_thread

	movl $0, next_thread

	popl %ebp
	popl %edi
	popl %esi
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	addl $0x4, %esp
	
	ret    /* return to ra */
