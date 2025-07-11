#pragma once

#include <stdint.h>

enum {
	sector_size = 512,
	ents_in_dir = 15,
};

struct dirent {
	uint32_t offset_sectors;
	uint32_t size_bytes;
	uint32_t reserved;
	char name[20];
};

struct dir {
	char reserved[32];
	struct dirent entries[ents_in_dir];
};

struct stat {
	uint32_t size;
	uint32_t reserved[3];
};

int stat(const char* name, struct stat *buf);

int read_file(const char* name, void* buf, uint32_t bufsize);
