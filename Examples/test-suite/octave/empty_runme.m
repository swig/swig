empty

printf("begin\n");
who global

printf("after load\n");
who global

#clear -g
printf("after clear\n");
who global

#clear empty
printf("after clear specific\n");
who global

printf("before shutdown\n");
