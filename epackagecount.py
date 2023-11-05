#!/usr/bin/env python3

import portage
print("Pakete:", len(portage.db["/"]["vartree"].dbapi.cpv_all()))
