//These functions inside the asm file
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
/**
* TODO: Show data on 7-seg via max7219_send
* Input:
* 		data: decimal value
* 		num_digs: number of digits will show on 7-seg
* Return:
* 	0: success
* 	-1: illegal data range(out of 8 digits range)
*/
int display(int data, int num_digs) {
	if(num_digs > 8)
		return -1;

	for(int i = 1; i <= num_digs; i++)
	{
		max7219_send(i, data%10);
		data/=10;
	}
	return 0;
}

void main() {
	int student_id = 1234567;
	GPIO_init();
	max7219_init();
	display(student_id, 9);
}
