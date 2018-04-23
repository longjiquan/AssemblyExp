#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#define GOODS_NUM 30
#define SHOP_NUM 2

typedef struct goodsInfo {
	char goodsName[10];
	short buyingPrice;
	short soldPrice;
	short buyNum;
	short soldNum;
	short apr;
}GoodsInfo;
typedef struct shopInfo {
	char shopName[10];
	GoodsInfo goods[GOODS_NUM];
}ShopInfo;
ShopInfo systemData[SHOP_NUM];
void function1(char* name, char* password);
#ifdef __cplusplus
extern "C" {
#endif
	int isGoods(int firstAddr,int goodsNameAddr);
#ifdef __cplusplus
}
#endif // __cplusplus
void function3_2_query(void);
void function3_3_change(void);
void function3_4_count_apr(void);
void function3_5_apr_rank(void);
void function3_6_output(void);
void SuccussMenu(void);//菜单显示函数
void FailMenu(void);
int main(void)
{
	strcpy(systemData[0].shopName, "SHOP1");
	strcpy(systemData[1].shopName, "SHOP2");
	strcpy(systemData[0].goods[0].goodsName, "PEN");
	strcpy(systemData[0].goods[1].goodsName, "BOOK");
	strcpy(systemData[1].goods[0].goodsName, "PEN");
	strcpy(systemData[1].goods[1].goodsName, "BOOK");
	int i, j;
	for (i = 2; i < GOODS_NUM; i++) {
		for (j = 0; j < SHOP_NUM; j++) {
			strcpy(systemData[j].goods[i].goodsName, "TEMPVALUE");
		}
	}
	srand((unsigned)time(NULL));
	for (i = 0; i < GOODS_NUM; i++) {
		for (j = 0; j < SHOP_NUM; j++) {
			systemData[j].goods[i].soldPrice = (unsigned short)rand();
			systemData[j].goods[i].buyNum = (unsigned short)rand();
			systemData[j].goods[i].buyingPrice = (unsigned short)rand()%(systemData[j].goods[i].soldPrice);
			systemData[j].goods[i].soldNum = (unsigned short)rand()%(systemData[j].goods[i].buyNum);
		}
	}
	char bossName[10] = "LONG JQ";
	char bossPass[10] = "NOPASS";
	char name[10], password[10];
	int auth = 0;
	while (1) {
		/*function1&function2*/
		function1(name, password);
		if (strlen(name) == 0) {
			/*输入回车*/
			auth = 0;
		}
		else if (strlen(name) != 1
			&& strcmp(name, bossName) == 0 
			&& strcmp(password, bossPass) == 0) {
			/*登陆成功*/
			auth = 1;
		}
		else if (name[0] == 'q' || name[0] == 'Q') {
			/*程序退出*/
			printf("end of program!\n");
			break;
		}
		else {
			/*登录失败*/
			printf("login failed!\n");
			continue;
		}
		/*function3*/
		if (auth == 1) {
			/*登陆成功*/
			SuccussMenu();
		}
		else {
			FailMenu();
		}
	}
}
void function1(char * name, char * password)
{
	printf("please input your name(q/Q to quit):");
	fgets(name, 10, stdin); name[strlen(name) - 1] = '\0';
	printf("please input your password:");
	fgets(password, 10, stdin); password[strlen(password) - 1] = '\0';
}
void function3_2_query(void)
{
	char goodsName[10] = {0};
	printf("please input the goods name:");
	fgets(goodsName, 10, stdin); goodsName[strlen(goodsName) - 1] = '\0';
	int goodsAddr = (int*)(systemData[0].goods[0].goodsName);
	int i = isGoods(goodsAddr,goodsName)/20;
	if (i == GOODS_NUM) {
		printf("goods not found!\n");
		return;
	}
	int j;
	for (j = 0; j < SHOP_NUM; j++) {
		printf("shop name:%s\n", systemData[j].shopName);
		printf("goods name:%s\n", systemData[j].goods[i].goodsName);
		printf("goods buying price:%hd\n", systemData[j].goods[i].buyingPrice);
		printf("goods sold price:%hd\n", systemData[j].goods[i].soldPrice);
		printf("goods buy num:%hd\n", systemData[j].goods[i].buyNum);
		printf("goods sold num:%hd\n", systemData[j].goods[i].soldNum);
	}
}
void function3_3_change(void)
{
	char goodsName[10];
	char shopName[10];
	printf("please input the shop name:");
	fgets(shopName, 10, stdin); shopName[strlen(shopName) - 1] = '\0';
	printf("please input the goods name:");
	fgets(goodsName, 10, stdin); goodsName[strlen(goodsName) - 1] = '\0';
	int j;
	for (j = 0; j < SHOP_NUM; j++) {
		if (strcmp(systemData[j].shopName, shopName) == 0) {
			break;
		}
	}
	if (j == SHOP_NUM) {
		printf("shop not found!\n");
		return;
	}
	int i = 0;
	for (; i < GOODS_NUM; i++) {
		if (strcmp(systemData[0].goods[i].goodsName, goodsName) == 0) {
			printf("goods found!\n");
			break;
		}
	}
	if (i == GOODS_NUM) {
		printf("goods not found!\n");
		return;
	}
	short shTemp;
	printf("goods buying price:%hd>>", systemData[j].goods[i].buyingPrice);
	scanf("%hd", &shTemp); getchar();
	systemData[j].goods[i].buyingPrice = shTemp;
	printf("goods buy num:%hd>>", systemData[j].goods[i].buyNum);
	scanf("%hd", &shTemp); getchar();
	systemData[j].goods[i].buyNum = shTemp;
	printf("goods sold price:%hd>>", systemData[j].goods[i].soldPrice);
	scanf("%hd", &shTemp); getchar();
	systemData[j].goods[i].soldPrice = shTemp;
}
void function3_4_count_apr(void)
{
	int i, j;
	for (i = 0; i < GOODS_NUM; i++) {
		short apr=0;
		short aprPart[SHOP_NUM] = { 0 };
		for (j = 0; j < SHOP_NUM; j++) {
			short soldPrice = systemData[j].goods[i].soldPrice;
			short soldNum = systemData[j].goods[i].soldNum;
			short buyingPrice = systemData[j].goods[i].buyingPrice;
			short buyingNum = systemData[j].goods[i].buyNum;
			int cost = buyingNum*buyingPrice;
			int profit = (soldPrice*soldNum - buyingPrice*buyingNum) * 100;
			aprPart[j] = (short)(profit / (cost));
			apr += aprPart[j];
		}
		systemData[0].goods[i].apr = apr / SHOP_NUM;
	}
}
void function3_5_apr_rank(void)
{
	int i, j;
	for (i = 0; i < GOODS_NUM; i++) {
		systemData[1].goods[i].apr = 1;/*排名置1*/
	}
	for (i = 0; i < GOODS_NUM; i++) {
		short cur_apr = systemData[0].goods[i].apr;
		int k;
		for (k = 0; k < GOODS_NUM; k++) {
			short other_apr = systemData[0].goods[k].apr;
			if (other_apr > cur_apr) {
				systemData[1].goods[i].apr++;
			}
		}
	}
}
void function3_6_output(void)
{
	int i, j;
	printf("shop  \t goods    \tbuying price\tsold price\tbuy num\tsold num\t apr \trank\n");
	for (j = 0; j < SHOP_NUM; j++) {
		for (i = 0; i < GOODS_NUM; i++) {
			printf("%6s\t%10s\t%12hd\t%10hd\t%7hd\t%8hd\t%3hd%%\t%4hd\n", systemData[j].shopName,
				systemData[j].goods[i].goodsName,
				systemData[j].goods[i].buyingPrice,
				systemData[j].goods[i].soldPrice,
				systemData[j].goods[i].buyNum,
				systemData[j].goods[i].soldNum,
				systemData[0].goods[i].apr,
				systemData[1].goods[i].apr);
			/*printf("%s", systemData[j].shopName);
			printf("good%s\n", systemData[j].goods[i].goodsName);
			printf("goods buying price:%hd\n", systemData[j].goods[i].buyingPrice);
			printf("goods sold price:%hd\n", systemData[j].goods[i].soldPrice);
			printf("goods buy num:%hd\n", systemData[j].goods[i].buyNum);
			printf("goods sold num:%hd\n", systemData[j].goods[i].soldNum);*/
			if ((i-1) % 3 == 0) {
				getchar();
			}
		}
	}
}
void SuccussMenu(void)
{
	printf("\t1=query goods，\t2=change goods\n");
	printf("\t3=calc apr，\t4=rank apr\n");
	printf("\t5=output all，\t6=exit\n");
	char choice;
	printf("Please input your choice(1-6):");
	choice = getchar(); getchar();
	switch (choice)
	{
	case '1':
		function3_2_query();
		break;
	case '2':
		function3_3_change();
		break;
	case '3':
		function3_4_count_apr();
		break;
	case '4':
		function3_5_apr_rank();
		break;
	case '5':
		function3_6_output();
		break;
	case '6':
		printf("enf of program！\n");
		exit(-1);
	default:
		printf("error input!\n");
		break;
	}
}
void FailMenu(void) {
	printf("\t1=query goods，\t6=exit\n");
	char choice;
	printf("Please input your choice(1/6):");
	choice = getchar();
	switch (choice)
	{
	case '1':
		function3_2_query();
		break;
	case '6':
		printf("enf of program！\n");
		exit(-1);
	default:
		printf("error input!\n");
		break;
	}
}
