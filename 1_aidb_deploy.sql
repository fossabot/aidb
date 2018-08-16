--- CREATE USER docker;
--- CREATE DATABASE aidb;
--- GRANT ALL PRIVILEGES ON DATABASE aidb TO docker;
CREATE SCHEMA aidb;

---
--- COUNTRY
---
CREATE TABLE aidb.country (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    iso TEXT,
    whole_name TEXT,
    nicename TEXT, 
    iso3 TEXT, 
    numcode INTEGER, 
    phonecode INTEGER
    );

COMMENT ON TABLE aidb.country IS 'Countries';

---
--- LOCATION or address
---
CREATE TABLE aidb.location (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    description TEXT,
    country  INTEGER REFERENCES aidb.country (id),
    town TEXT,
    street TEXT,
    zipcode TEXT);

COMMENT ON TABLE aidb.location IS 'Location or address of asset/person/company';

---
--- ROOM in building
---
CREATE TABLE aidb.room (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    loc  INTEGER REFERENCES aidb.location (id),
    floor TEXT,
    room_number INTEGER,
    room_name TEXT
    );

COMMENT ON TABLE aidb.room IS 'Room in building where DC is situated';

---
--- SITE or logical group
---
CREATE TABLE aidb.site (
    room  INTEGER REFERENCES aidb.room (id),
    site_name TEXT PRIMARY KEY
    );

---
--- CONTACT
---
CREATE TABLE aidb.contact (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    name TEXT,
    surname TEXT,
    phone TEXT,
    phone2 TEXT,
    email TEXT,
    email2 TEXT,
    other TEXT ---fax and others
);

COMMENT ON TABLE aidb.contact IS 'Contact to employee or company or vendor';

---
--- PURCHASE ORDER
---
CREATE TABLE aidb.purchase_order (
    financial_id TEXT PRIMARY KEY,
    financial_location_id TEXT,
    invoice_number TEXT,
    purchase_url TEXT,
    contact INTEGER REFERENCES aidb.contact (id)
    );


---
--- LICENSE OWNERSHIP
---
CREATE TYPE aidb.license_ownership AS ENUM ('purchased', 'trial', 'leased');

---
--- SOFTWARE
---
CREATE TABLE aidb.software (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    name TEXT,
    version TEXT,
    vendor TEXT,
    description TEXT,
    serial_key TEXT,
    expire_on DATE,
    ownership aidb.license_ownership DEFAULT 'trial',
    support_contact INTEGER REFERENCES aidb.contact (id),
    support_url TEXT,
    software_url TEXT, --- for cloud based software
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id)
    );


---
--- SERVICE LEVEL AGREEMENT is a commitment between a service provider and a client. Particular aspects of the service
--- – quality, availability, responsibilities – are agreed between the service provider and the service user.
---
CREATE TABLE aidb.sla ( 
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    name TEXT,
    version TEXT,
    service TEXT, --- Type of service to be provided
    performance_level TEXT, ---  desired performance level, especially its reliability and responsiveness
    support_contact INTEGER REFERENCES aidb.contact (id),
    response_time TEXT, --- Response and issue resolution time-frame
    resolution_time TEXT,
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id)
    );

COMMENT ON TABLE aidb.sla IS 'Service Level Agreement -  is a commitment between a service provider and a client.';

--- SLA: Service level agreements can contain numerous service performance metrics with corresponding service level objectives.
--- A common case in IT service management is a call center or service desk. Metrics commonly agreed to in these cases include:
-- Abandonment Rate: Percentage of calls abandoned while waiting to be answered.
-- ASA (Average Speed to Answer): Average time (usually in seconds) it takes for a call to be answered by the service desk.
-- TSF (Time Service Factor): Percentage of calls answered within a definite timeframe, e.g., 80% in 20 seconds.
-- FCR (First-Call Resolution): Percentage of incoming calls that can be resolved without the use of a callback or without having the caller call back the helpdesk to finish resolving the case.[6]
-- TAT (Turn-Around Time): Time taken to complete a certain task.
-- MTTR (Mean Time To Recover): Time taken to recover after an outage of service.



---
--- RACK
---
CREATE TABLE aidb.rack(
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    rack_name TEXT,
    rack_size INTEGER, --- number of positions 
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id),
    rack_site TEXT REFERENCES aidb.site (site_name)
    );  --- SITE in netbox

COMMENT ON TABLE aidb.rack IS 'Rack with n positions in room';

--- CREATE INDEX location_idx ON aidb.location (id);

--- TODO: sort out
--- LICENSE TYPE
-- Appliance:  A license covering use of a specific piece of hardware, such as a hub, router, or PBX. Terms and conditions vary between vendors.
-- User:   A license that provides access to the software to a specific number of users. All installations of the software will be counted but installations across multiple devices for the same user will be counted as one license consumption.
-- Concurrent User:  A license which provides wider access to the software but limits the number of simultaneous users using the software. It may or may not include compliance enforcement capabilities. Typically, a concurrent license is “checked out” from the license server when the software is run, assuming a license is available. If no license is available, the requester experiences a denial of service.
-- Named User:  A license that allows access to the software by a specific number of named users. In some cases, these licenses can be transferred from one user to another. When you create the license, you should allocate the license to specific users. Only installations associated with allocated users are counted. For example, if the license is allocated to users Sam and Jan, the maximum installation count is two. Any other installations of the licensed application are treated as unassigned installations. For example, if May has also installed the licensed application but has not been allocated to the license, her installation will not be shown against installations of this license.
-- Enterprise:   A license to install software an unlimited number of times within the enterprise. An Enterprise Agreement, such as the Microsoft EA, is defined separately to this in FlexNet Manager Suite (FNMS). An Enterprise Agreement is structured as ‘all you can eat’ but the organization must be licensed for a specific quantity of licenses so this is not strictly an ‘Enterprise License’ model in its pure form.
-- Evaluation:  A license that allows one or more users to install and use software for trial purposes. Evaluation licenses may be time limited, may offer limited functionality, or may restrict or mark output (for example, some PDF writing software includes the name of the software on every PDF document produced from a trial version). After evaluation, a user may purchase a full license, uninstall the software, or (for time-limited trials) the software will simply no longer work.
-- Node Locked:  A license that allows access to the software on a specific number of named computers. These licenses are usually for server applications such as database or VMware products. In some cases, these licenses can be transferred from one computer to another, usually by requesting a new license key.
-- OEM:  A license for software that is delivered with the hardware and is only for use on that piece of hardware. These licenses are tied to the lifecycle of the hardware and typically cannot be transferred to other hardware.
-- Processor (per Processor/CPU):   A license based on the number of  CPU/Processor sockets on which the software will run, and NOT the logical processors aka cores.
-- Client Server:  A server license that is based on a device metric. In many cases this type of license may also have a Client Access License (or CAL) aspect. In a Server/CAL model a license must be purchased for the physical server (or virtual server – there are varying rules around virtualisation) and also additional ‘access’ licenses must be purchased for any users/devices that may access the server for that application.
-- Run-Time:  A license that provides access rights to third party software embedded in an application. The use of the runtime license is limited to the application through which it has been acquired.
-- Site:  A license to install software on an unlimited number of computers at one physical location.
-- Device (most common metric):  A license for a defined number of software installations. The software may be uninstalled on one computer and installed on any other computer within the same enterprise, so long as the total number of installations does not exceed the number of  purchased licenses.
-- Core/Processor points:   A license based on points applied as a multiplier to the number of Cores/Processors in the physical server, or in some cases, the virtual machine. Some vendors count Processor sockets and others count logical processors, or cores, but the license model is similar. For example an application installed on a 4 processor server with 100 points per processor would require a purchase of 400 processor points to cover the license liability. These licenses are mainly used for Datacenter software licensing such as IBM.
CREATE TYPE aidb.license_model AS ENUM ('appliance', --- covering use of a specific piece of hardware
    'user',
    'concurrent_user',
    'named_user', --- that allows access to the software by a specific number of named users.
    'enterprise',
    'evaluation',
    'node_locked',
    'oem',
    'per_cpu',
    'client_server',
    'runtime',
    'site',
    'device',
    'cpu_points'
);


---
--- LICENSE of hw and sw
---
CREATE TABLE aidb.license (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    license_name TEXT,
    description TEXT,
    lic_type  aidb.license_model,
    support_contract_id TEXT,
    support_contract_url TEXT,
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id),
    expire_on DATE);

COMMENT ON TABLE aidb.license IS 'Any software license';


---CREATE INDEX contact_id_index ON aidb.contact (name, phone, email);

---
--- CORPORATION
---
CREATE TABLE aidb.corporation (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    name TEXT,
    tax_id TEXT,
    bank_acc_iban TEXT,
    bank_acc_swift TEXT,
    address INTEGER REFERENCES aidb.location (id),
    contact INTEGER REFERENCES aidb.contact (id),
    descr TEXT);

COMMENT ON TABLE aidb.corporation IS 'Corporation and main contact/address';

---
--- DEPARTMENT
---
CREATE TABLE aidb.department (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    corp_id INTEGER REFERENCES aidb.corporation (id),
    dept_name TEXT,
    dept_descr TEXT);

COMMENT ON TABLE aidb.location IS 'Department in company';

---
--- EMPLOYEE
---
CREATE TABLE aidb.employee (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    dept_id INTEGER REFERENCES aidb.department (id),
    contact INTEGER REFERENCES aidb.contact (id),
    descr TEXT);

COMMENT ON TABLE aidb.location IS 'Employee of company';

---
--- PROJECT
---
CREATE TABLE aidb.project (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    contact INTEGER REFERENCES aidb.employee (id),
    name TEXT,
    descr TEXT);

COMMENT ON TABLE aidb.location IS 'Project of team in department';

---
--- PROJECT MEMBER
---
CREATE TABLE aidb.proj_member (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    proj_id INTEGER REFERENCES aidb.project (id),
    employee INTEGER REFERENCES aidb.employee (id),
    role_descr TEXT);

COMMENT ON TABLE aidb.location IS 'Member of the project';


---
--- HOST type
---
CREATE TYPE aidb.host_type AS ENUM ('physical',
    'virtual',
    'not_specified'
);


---
--- HOST category
---
CREATE TYPE aidb.host_category AS ENUM ('server',
    'hypervisor',
    'router',
    'switch',
    'ups',
    'firewall'
);

---
--- HARDWARE - whole server, not component
---
CREATE TABLE aidb.hw (
    serial_number TEXT PRIMARY KEY,
    manufacturer TEXT,
    model TEXT,
    warranty_to DATE,
    support_level TEXT,
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id));

COMMENT ON TABLE aidb.hw IS 'HW is hardware (which can be server, router, switch.. etc)';


---
--- POSITION IN RACK
---
CREATE TABLE aidb.hw_pos_in_rack(
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    rack INTEGER REFERENCES aidb.rack (id),
    rack_position TEXT, --- text, because it can be also "5-6".. taking 2 positions
    hw TEXT REFERENCES aidb.hw (serial_number)
    );

COMMENT ON TABLE aidb.hw_pos_in_rack IS 'Position of HW in rack';

---
--- MOTHERBOARD
---
CREATE TABLE aidb.motherboard (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    vendor TEXT REFERENCES aidb.hw (serial_number),  --- either it belongs to storage/server or it's single hdd in stock
    model TEXT, -- product
    serial_num INTEGER,
    warranty_to DATE,
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id));

COMMENT ON TABLE aidb.motherboard IS 'Motherboard info';

---
--- HDD type
---
CREATE TYPE aidb.storage_type AS ENUM ('hdd', 'ssd', 'sd', 'other');

---
--- HDD
---
CREATE TABLE aidb.hdd (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    host TEXT REFERENCES aidb.hw (serial_number),  --- either it belongs to storage/server or it's single hdd in stock
    serial_num TEXT,
    manufacturer TEXT,
    storage_type aidb.storage_type,
    size_gb INTEGER,
    hdd_slot INTEGER,
    rpm  INTEGER,
    warranty_to DATE,
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id));

COMMENT ON TABLE aidb.hdd IS 'Hard disk info';

---
--- CPU
---
CREATE TABLE aidb.cpu (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    host TEXT REFERENCES aidb.hw (serial_number), 
    vendor TEXT, --- lscpu |grep 'Vendor'
    model TEXT, --- lscpu |grep 'Model name'   
    slot INTEGER,   --- TODO: add automaticaly
    cpu_speed TEXT,
    socket_number INTEGER,
    warranty_to DATE,
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id));

COMMENT ON TABLE aidb.cpu IS 'Physical CPU info';

---
--- MEMORY
---
CREATE TABLE aidb.ram (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    hw_host TEXT REFERENCES aidb.hw (serial_number),
    model TEXT, -- product
    vendor TEXT,
    module_description INTEGER,
    size TEXT,
    slot TEXT,
    ram_speed TEXT,
    warranty_to DATE,
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id));

---
--- PSU
---
CREATE TABLE aidb.power_supply (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    hw_host TEXT REFERENCES aidb.hw (serial_number),
    model TEXT, -- product
    vendor TEXT,
    module_description INTEGER,
    warranty_to DATE,
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id));

---
--- FAN
---
CREATE TABLE aidb.fan (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    hw_host TEXT REFERENCES aidb.hw (serial_number),
    model TEXT, -- product
    vendor TEXT,
    module_description INTEGER,
    warranty_to DATE,
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id));

---
--- NIC type
---
CREATE TYPE aidb.nic_type AS ENUM ('ether',
    'fibre',
    'management_module',
    'infiniband'
);

---
--- NIC
---
CREATE TABLE aidb.network_interface (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    nic_t aidb.nic_type DEFAULT 'ether',
    hw_host TEXT REFERENCES aidb.hw (serial_number),
    model TEXT,
    vendor TEXT,
    warranty_to DATE,
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id));


---
--- NIC type
---
CREATE TYPE aidb.os_type AS ENUM ('general_purpose',
    'atomic_host'
);

---
--- Importance type
---
-- CREATE TYPE aidb.importance_type AS ENUM ('critical',
--     'non-critical',
--     'to_decomission'
-- );

---
--- OS
---
CREATE TABLE aidb.operating_system (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    hw_host TEXT REFERENCES aidb.hw (serial_number),
    vendor TEXT, --- canonical,ubuntu
    os_release TEXT,
    os_name TEXT, -- uname -o
    pretty_name TEXT,
    kernel_version TEXT,   --- uname -r / 4.14.18-300.fc27.x86_64
    arch text, --- uname -m/-p
    ostype aidb.os_type DEFAULT 'general_purpose',
    supported_until DATE,
    license INTEGER REFERENCES aidb.license(id),
    purchase_order TEXT REFERENCES aidb.purchase_order (financial_id));


---
--- HOST (normal physical server)
---
CREATE TABLE aidb.host(
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    hostname TEXT,
    host_t aidb.host_type DEFAULT 'not_specified',
    physical_host TEXT REFERENCES aidb.hw (serial_number));

CREATE INDEX host_id_index ON aidb.host(id);

---
--- JUMP SERVERS / this table works other way round, we care about IP address and nothing else.. 
--- usually jumps are restricted only to create ssh tunnel to other machines... 
--- running any commands (including HW scan) is forbidden
---
CREATE TABLE aidb.jump_servers (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    host_t aidb.host_type DEFAULT 'not_specified',
    host INTEGER REFERENCES aidb.host(id),
    );

COMMENT ON TABLE aidb.jump_servers IS 'list of jump servers';

--- TODO: view on ip and fqdn

---
--- ROUTER
---
CREATE TABLE aidb.router (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    hostname TEXT,
    host_t aidb.host_type DEFAULT 'not_specified',
    physical_host TEXT REFERENCES aidb.hw (serial_number));

CREATE INDEX router_id_index ON aidb.router (id);

---
--- FIREWALL
---
CREATE TABLE aidb.firewall (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    hostname TEXT,
    host_t aidb.host_type DEFAULT 'not_specified',
    physical_host TEXT REFERENCES aidb.hw (serial_number));

CREATE INDEX fw_id_index ON aidb.firewall (id);


---
--- SWITCH
---
CREATE TYPE aidb.switch_type AS ENUM ('core',
    'spine-aggregation',
    'leaf-access-tor',
    'end_of_row-bor',
    'not_specified'
);

CREATE TABLE aidb.switch (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    hostname TEXT,
    host_t aidb.switch_type DEFAULT 'not_specified',
    physical_host TEXT REFERENCES aidb.hw (serial_number));

--- CREATE INDEX switch_id_index ON aidb.switch (id);



CREATE TABLE aidb.printer (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    hostname TEXT,
    description TEXT,
    physical_host TEXT REFERENCES aidb.hw (serial_number));


---
--- STORAGE SERVER
---
CREATE TABLE aidb.storage_server (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    hostname TEXT,
    host_t aidb.host_type DEFAULT 'not_specified',
    physical_host TEXT REFERENCES aidb.hw (serial_number));

CREATE INDEX storage_serv_id_index ON aidb.storage_server (id);

---
--- VIRTUAL HOST
---
CREATE TABLE aidb.virtual_host (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    host INTEGER REFERENCES aidb.host(id),
    vcpu INTEGER,
    ram INTEGER,
    vhd INTEGER);



---
--- Network PORT (physical port on NIC)
---
CREATE TABLE aidb.network_port (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    nic INTEGER REFERENCES aidb.network_interface(id),
    mac macaddr,
    ip_addr  inet,
    mtu INTEGER);


---
--- Network BOND
---
CREATE TABLE aidb.bond (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    bond_name TEXT,
    ip_addr inet,
    nic_port INTEGER REFERENCES aidb.network_port(id),
    bond_description TEXT);
---
--- network bridge
---
CREATE TABLE aidb.bridge (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    net_port INTEGER REFERENCES aidb.network_port(id),
    net_bond INTEGER REFERENCES aidb.bond(id),
    br_name TEXT);

-- TUN, TAP devices are entirely virtual
--  in contrast to other devices on your system (e.g eth0) which associated with a physical address.

-- A TUN device operates in the third  OSI layer (network) and used mostly for routing traffic,
--  while a TAP device operates in the second OSI layer (data link) and used to process Ethernet frames.
CREATE TABLE aidb.tun (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    tag TEXT,
    br INTEGER REFERENCES aidb.bridge(id),
    tun_name INTEGER);

CREATE TABLE aidb.tap (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    tag TEXT,
    br INTEGER REFERENCES aidb.bridge(id),
    tap_name INTEGER);

--- TODO: NIC

---
--- CONTAINER
---
CREATE TABLE aidb.container (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    cont_id TEXT,
    container_name TEXT,
    image TEXT,
    host INTEGER REFERENCES aidb.host(id));

---
--- SERVICES
---
CREATE TYPE aidb.service_type AS ENUM ('ntp',
    'dns',
    'web',
    'ssh',
    'firewall',
    'db',
    'network_storage',
    'not_specified'
);

CREATE TYPE aidb.cloud_service_type AS ENUM ('networking',
    'compute',
    'block_storage',
    'image_storage',
    'object_storage',
    'telemetry',
    'identity',
    'orchestration',
    'dashboard'
);

CREATE TABLE aidb.service (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    serv_type aidb.service_type,
    serv_name TEXT,
    descr TEXT,
    service_status TEXT,
    host INTEGER REFERENCES aidb.host(id));

CREATE TABLE aidb.dns_records (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    fqdn TEXT DEFAULT 'localhost.localdomain',
    ipv4 INTEGER REFERENCES aidb.network_port(id),
    bondipv4 INTEGER REFERENCES aidb.bond(id)
);



---
---
--- OPENSTACK CLOUD
---


CREATE TABLE aidb.cloud (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    cloud_name TEXT,
    vendor TEXT,
    cloud_version TEXT);


CREATE TABLE aidb.projects ( --- tenants
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    tenant_name TEXT,
    quota_cores TEXT,
    quota_ram INTEGER,
    quota_instances TEXT,
    quota_volumes TEXT,
    quota_size_gb TEXT,
    cloud INTEGER REFERENCES aidb.cloud(id));   --- ON DELETE CASCADE

CREATE TABLE aidb.images ( --- tenants
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    img_name TEXT,
    cloud INTEGER REFERENCES aidb.cloud(id));

CREATE TABLE aidb.flavors ( --- tenants
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    flavor_name TEXT,
    flavor_ram TEXT,
    flavor_disk INTEGER,
    flavor_vcpus TEXT,
    public TEXT,
    projects INTEGER REFERENCES aidb.projects(id));

CREATE TABLE aidb.compute_nodes (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    cloud INTEGER REFERENCES aidb.cloud(id),
    host INTEGER REFERENCES aidb.host(id));

CREATE TABLE aidb.management_nodes (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    cloud INTEGER REFERENCES aidb.cloud(id),
    host INTEGER REFERENCES aidb.host(id));

CREATE TYPE aidb.storage_node_type AS ENUM ('data','monitor','metadata');

CREATE TABLE aidb.storage_nodes (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    cloud INTEGER REFERENCES aidb.cloud(id),
    stor_type aidb.storage_node_type,
    host INTEGER REFERENCES aidb.host(id));

---
--- AVAILABILITY ZONE  (openstack/aws)
---
--- An availability zone groups network nodes that run services like DHCP, L3, FW, and others. 
--- It is defined as an agent’s attribute on the network node. This allows users to associate an availability zone with 
--- their resources so that the resources get high availability.
CREATE TABLE aidb.availability_zone(
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    cloud INTEGER REFERENCES aidb.cloud(id),
    zone_name TEXT
);


---
--- JUJU
---
CREATE TABLE aidb.juju_controllers (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    controller TEXT,
    controller_user TEXT,
    cloud_region TEXT,
    machines INTEGER,
    models INTEGER,
    access TEXT,
    juju_version TEXT,
    hw TEXT REFERENCES aidb.hw(serial_number));

CREATE TABLE aidb.juju_models (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    model_name TEXT,
    region TEXT,
    model_status  TEXT,
    machines INTEGER,
    cores  INTEGER,
    controller INTEGER REFERENCES aidb.juju_controllers(id));

--- MAAS   
CREATE TABLE aidb.maas_region_controller (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    fqdn TEXT,
    hw TEXT REFERENCES aidb.hw(serial_number),
    url  TEXT);


CREATE TABLE aidb.maas_machines (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    fqdn TEXT,
    mac macaddr,
    machine_owner  TEXT,
    region_controller INTEGER REFERENCES aidb.maas_region_controller(id),
    machine_status INTEGER);

CREATE TABLE aidb.maas_controllers (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    controller_name TEXT,
    controller_status TEXT,
    controller_type  TEXT,
    region_controller INTEGER REFERENCES aidb.maas_region_controller(id),
    last_image_sync DATE);

CREATE TABLE aidb.maas_devices (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    fqdn TEXT,
    mac macaddr,
    device_owner  TEXT,
    region_controller INTEGER REFERENCES aidb.maas_region_controller(id),
    device_status INTEGER);



    
---
--- load COUNTRY with data
---

INSERT INTO aidb.country (id, iso, whole_name, nicename, iso3, numcode, phonecode) VALUES
(1, 'AF', 'AFGHANISTAN', 'Afghanistan', 'AFG', 4, 93),
(2, 'AL', 'ALBANIA', 'Albania', 'ALB', 8, 355),
(3, 'DZ', 'ALGERIA', 'Algeria', 'DZA', 12, 213),
(4, 'AS', 'AMERICAN SAMOA', 'American Samoa', 'ASM', 16, 1684),
(5, 'AD', 'ANDORRA', 'Andorra', 'AND', 20, 376),
(6, 'AO', 'ANGOLA', 'Angola', 'AGO', 24, 244),
(7, 'AI', 'ANGUILLA', 'Anguilla', 'AIA', 660, 1264),
(8, 'AQ', 'ANTARCTICA', 'Antarctica', NULL, NULL, 0),
(9, 'AG', 'ANTIGUA AND BARBUDA', 'Antigua and Barbuda', 'ATG', 28, 1268),
(10, 'AR', 'ARGENTINA', 'Argentina', 'ARG', 32, 54),
(11, 'AM', 'ARMENIA', 'Armenia', 'ARM', 51, 374),
(12, 'AW', 'ARUBA', 'Aruba', 'ABW', 533, 297),
(13, 'AU', 'AUSTRALIA', 'Australia', 'AUS', 36, 61),
(14, 'AT', 'AUSTRIA', 'Austria', 'AUT', 40, 43),
(15, 'AZ', 'AZERBAIJAN', 'Azerbaijan', 'AZE', 31, 994),
(16, 'BS', 'BAHAMAS', 'Bahamas', 'BHS', 44, 1242),
(17, 'BH', 'BAHRAIN', 'Bahrain', 'BHR', 48, 973),
(18, 'BD', 'BANGLADESH', 'Bangladesh', 'BGD', 50, 880),
(19, 'BB', 'BARBADOS', 'Barbados', 'BRB', 52, 1246),
(20, 'BY', 'BELARUS', 'Belarus', 'BLR', 112, 375),
(21, 'BE', 'BELGIUM', 'Belgium', 'BEL', 56, 32),
(22, 'BZ', 'BELIZE', 'Belize', 'BLZ', 84, 501),
(23, 'BJ', 'BENIN', 'Benin', 'BEN', 204, 229),
(24, 'BM', 'BERMUDA', 'Bermuda', 'BMU', 60, 1441),
(25, 'BT', 'BHUTAN', 'Bhutan', 'BTN', 64, 975),
(26, 'BO', 'BOLIVIA', 'Bolivia', 'BOL', 68, 591),
(27, 'BA', 'BOSNIA AND HERZEGOVINA', 'Bosnia and Herzegovina', 'BIH', 70, 387),
(28, 'BW', 'BOTSWANA', 'Botswana', 'BWA', 72, 267),
(29, 'BV', 'BOUVET ISLAND', 'Bouvet Island', NULL, NULL, 0),
(30, 'BR', 'BRAZIL', 'Brazil', 'BRA', 76, 55),
(31, 'IO', 'BRITISH INDIAN OCEAN TERRITORY', 'British Indian Ocean Territory', NULL, NULL, 246),
(32, 'BN', 'BRUNEI DARUSSALAM', 'Brunei Darussalam', 'BRN', 96, 673),
(33, 'BG', 'BULGARIA', 'Bulgaria', 'BGR', 100, 359),
(34, 'BF', 'BURKINA FASO', 'Burkina Faso', 'BFA', 854, 226),
(35, 'BI', 'BURUNDI', 'Burundi', 'BDI', 108, 257),
(36, 'KH', 'CAMBODIA', 'Cambodia', 'KHM', 116, 855),
(37, 'CM', 'CAMEROON', 'Cameroon', 'CMR', 120, 237),
(38, 'CA', 'CANADA', 'Canada', 'CAN', 124, 1),
(39, 'CV', 'CAPE VERDE', 'Cape Verde', 'CPV', 132, 238),
(40, 'KY', 'CAYMAN ISLANDS', 'Cayman Islands', 'CYM', 136, 1345),
(41, 'CF', 'CENTRAL AFRICAN REPUBLIC', 'Central African Republic', 'CAF', 140, 236),
(42, 'TD', 'CHAD', 'Chad', 'TCD', 148, 235),
(43, 'CL', 'CHILE', 'Chile', 'CHL', 152, 56),
(44, 'CN', 'CHINA', 'China', 'CHN', 156, 86),
(45, 'CX', 'CHRISTMAS ISLAND', 'Christmas Island', NULL, NULL, 61),
(46, 'CC', 'COCOS (KEELING) ISLANDS', 'Cocos (Keeling) Islands', NULL, NULL, 672),
(47, 'CO', 'COLOMBIA', 'Colombia', 'COL', 170, 57),
(48, 'KM', 'COMOROS', 'Comoros', 'COM', 174, 269),
(49, 'CG', 'CONGO', 'Congo', 'COG', 178, 242),
(50, 'CD', 'CONGO, THE DEMOCRATIC REPUBLIC OF THE', 'Congo, the Democratic Republic of the', 'COD', 180, 242),
(51, 'CK', 'COOK ISLANDS', 'Cook Islands', 'COK', 184, 682),
(52, 'CR', 'COSTA RICA', 'Costa Rica', 'CRI', 188, 506),
(53, 'CI', 'COTE D''IVOIRE', 'Cote D''Ivoire', 'CIV', 384, 225),
(54, 'HR', 'CROATIA', 'Croatia', 'HRV', 191, 385),
(55, 'CU', 'CUBA', 'Cuba', 'CUB', 192, 53),
(56, 'CY', 'CYPRUS', 'Cyprus', 'CYP', 196, 357),
(57, 'CZ', 'CZECH REPUBLIC', 'Czech Republic', 'CZE', 203, 420),
(58, 'DK', 'DENMARK', 'Denmark', 'DNK', 208, 45),
(59, 'DJ', 'DJIBOUTI', 'Djibouti', 'DJI', 262, 253),
(60, 'DM', 'DOMINICA', 'Dominica', 'DMA', 212, 1767),
(61, 'DO', 'DOMINICAN REPUBLIC', 'Dominican Republic', 'DOM', 214, 1809),
(62, 'EC', 'ECUADOR', 'Ecuador', 'ECU', 218, 593),
(63, 'EG', 'EGYPT', 'Egypt', 'EGY', 818, 20),
(64, 'SV', 'EL SALVADOR', 'El Salvador', 'SLV', 222, 503),
(65, 'GQ', 'EQUATORIAL GUINEA', 'Equatorial Guinea', 'GNQ', 226, 240),
(66, 'ER', 'ERITREA', 'Eritrea', 'ERI', 232, 291),
(67, 'EE', 'ESTONIA', 'Estonia', 'EST', 233, 372),
(68, 'ET', 'ETHIOPIA', 'Ethiopia', 'ETH', 231, 251),
(69, 'FK', 'FALKLAND ISLANDS (MALVINAS)', 'Falkland Islands (Malvinas)', 'FLK', 238, 500),
(70, 'FO', 'FAROE ISLANDS', 'Faroe Islands', 'FRO', 234, 298),
(71, 'FJ', 'FIJI', 'Fiji', 'FJI', 242, 679),
(72, 'FI', 'FINLAND', 'Finland', 'FIN', 246, 358),
(73, 'FR', 'FRANCE', 'France', 'FRA', 250, 33),
(74, 'GF', 'FRENCH GUIANA', 'French Guiana', 'GUF', 254, 594),
(75, 'PF', 'FRENCH POLYNESIA', 'French Polynesia', 'PYF', 258, 689),
(76, 'TF', 'FRENCH SOUTHERN TERRITORIES', 'French Southern Territories', NULL, NULL, 0),
(77, 'GA', 'GABON', 'Gabon', 'GAB', 266, 241),
(78, 'GM', 'GAMBIA', 'Gambia', 'GMB', 270, 220),
(79, 'GE', 'GEORGIA', 'Georgia', 'GEO', 268, 995),
(80, 'DE', 'GERMANY', 'Germany', 'DEU', 276, 49),
(81, 'GH', 'GHANA', 'Ghana', 'GHA', 288, 233),
(82, 'GI', 'GIBRALTAR', 'Gibraltar', 'GIB', 292, 350),
(83, 'GR', 'GREECE', 'Greece', 'GRC', 300, 30),
(84, 'GL', 'GREENLAND', 'Greenland', 'GRL', 304, 299),
(85, 'GD', 'GRENADA', 'Grenada', 'GRD', 308, 1473),
(86, 'GP', 'GUADELOUPE', 'Guadeloupe', 'GLP', 312, 590),
(87, 'GU', 'GUAM', 'Guam', 'GUM', 316, 1671),
(88, 'GT', 'GUATEMALA', 'Guatemala', 'GTM', 320, 502),
(89, 'GN', 'GUINEA', 'Guinea', 'GIN', 324, 224),
(90, 'GW', 'GUINEA-BISSAU', 'Guinea-Bissau', 'GNB', 624, 245),
(91, 'GY', 'GUYANA', 'Guyana', 'GUY', 328, 592),
(92, 'HT', 'HAITI', 'Haiti', 'HTI', 332, 509),
(93, 'HM', 'HEARD ISLAND AND MCDONALD ISLANDS', 'Heard Island and Mcdonald Islands', NULL, NULL, 0),
(94, 'VA', 'HOLY SEE (VATICAN CITY STATE)', 'Holy See (Vatican City State)', 'VAT', 336, 39),
(95, 'HN', 'HONDURAS', 'Honduras', 'HND', 340, 504),
(96, 'HK', 'HONG KONG', 'Hong Kong', 'HKG', 344, 852),
(97, 'HU', 'HUNGARY', 'Hungary', 'HUN', 348, 36),
(98, 'IS', 'ICELAND', 'Iceland', 'ISL', 352, 354),
(99, 'IN', 'INDIA', 'India', 'IND', 356, 91),
(100, 'ID', 'INDONESIA', 'Indonesia', 'IDN', 360, 62),
(101, 'IR', 'IRAN, ISLAMIC REPUBLIC OF', 'Iran, Islamic Republic of', 'IRN', 364, 98),
(102, 'IQ', 'IRAQ', 'Iraq', 'IRQ', 368, 964),
(103, 'IE', 'IRELAND', 'Ireland', 'IRL', 372, 353),
(104, 'IL', 'ISRAEL', 'Israel', 'ISR', 376, 972),
(105, 'IT', 'ITALY', 'Italy', 'ITA', 380, 39),
(106, 'JM', 'JAMAICA', 'Jamaica', 'JAM', 388, 1876),
(107, 'JP', 'JAPAN', 'Japan', 'JPN', 392, 81),
(108, 'JO', 'JORDAN', 'Jordan', 'JOR', 400, 962),
(109, 'KZ', 'KAZAKHSTAN', 'Kazakhstan', 'KAZ', 398, 7),
(110, 'KE', 'KENYA', 'Kenya', 'KEN', 404, 254),
(111, 'KI', 'KIRIBATI', 'Kiribati', 'KIR', 296, 686),
(112, 'KP', 'KOREA, DEMOCRATIC PEOPLE''S REPUBLIC OF', 'Korea, Democratic People''s Republic of', 'PRK', 408, 850),
(113, 'KR', 'KOREA, REPUBLIC OF', 'Korea, Republic of', 'KOR', 410, 82),
(114, 'KW', 'KUWAIT', 'Kuwait', 'KWT', 414, 965),
(115, 'KG', 'KYRGYZSTAN', 'Kyrgyzstan', 'KGZ', 417, 996),
(116, 'LA', 'LAO PEOPLE''S DEMOCRATIC REPUBLIC', 'Lao People''s Democratic Republic', 'LAO', 418, 856),
(117, 'LV', 'LATVIA', 'Latvia', 'LVA', 428, 371),
(118, 'LB', 'LEBANON', 'Lebanon', 'LBN', 422, 961),
(119, 'LS', 'LESOTHO', 'Lesotho', 'LSO', 426, 266),
(120, 'LR', 'LIBERIA', 'Liberia', 'LBR', 430, 231),
(121, 'LY', 'LIBYAN ARAB JAMAHIRIYA', 'Libyan Arab Jamahiriya', 'LBY', 434, 218),
(122, 'LI', 'LIECHTENSTEIN', 'Liechtenstein', 'LIE', 438, 423),
(123, 'LT', 'LITHUANIA', 'Lithuania', 'LTU', 440, 370),
(124, 'LU', 'LUXEMBOURG', 'Luxembourg', 'LUX', 442, 352),
(125, 'MO', 'MACAO', 'Macao', 'MAC', 446, 853),
(126, 'MK', 'MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF', 'Macedonia, the Former Yugoslav Republic of', 'MKD', 807, 389),
(127, 'MG', 'MADAGASCAR', 'Madagascar', 'MDG', 450, 261),
(128, 'MW', 'MALAWI', 'Malawi', 'MWI', 454, 265),
(129, 'MY', 'MALAYSIA', 'Malaysia', 'MYS', 458, 60),
(130, 'MV', 'MALDIVES', 'Maldives', 'MDV', 462, 960),
(131, 'ML', 'MALI', 'Mali', 'MLI', 466, 223),
(132, 'MT', 'MALTA', 'Malta', 'MLT', 470, 356),
(133, 'MH', 'MARSHALL ISLANDS', 'Marshall Islands', 'MHL', 584, 692),
(134, 'MQ', 'MARTINIQUE', 'Martinique', 'MTQ', 474, 596),
(135, 'MR', 'MAURITANIA', 'Mauritania', 'MRT', 478, 222),
(136, 'MU', 'MAURITIUS', 'Mauritius', 'MUS', 480, 230),
(137, 'YT', 'MAYOTTE', 'Mayotte', NULL, NULL, 269),
(138, 'MX', 'MEXICO', 'Mexico', 'MEX', 484, 52),
(139, 'FM', 'MICRONESIA, FEDERATED STATES OF', 'Micronesia, Federated States of', 'FSM', 583, 691),
(140, 'MD', 'MOLDOVA, REPUBLIC OF', 'Moldova, Republic of', 'MDA', 498, 373),
(141, 'MC', 'MONACO', 'Monaco', 'MCO', 492, 377),
(142, 'MN', 'MONGOLIA', 'Mongolia', 'MNG', 496, 976),
(143, 'MS', 'MONTSERRAT', 'Montserrat', 'MSR', 500, 1664),
(144, 'MA', 'MOROCCO', 'Morocco', 'MAR', 504, 212),
(145, 'MZ', 'MOZAMBIQUE', 'Mozambique', 'MOZ', 508, 258),
(146, 'MM', 'MYANMAR', 'Myanmar', 'MMR', 104, 95),
(147, 'NA', 'NAMIBIA', 'Namibia', 'NAM', 516, 264),
(148, 'NR', 'NAURU', 'Nauru', 'NRU', 520, 674),
(149, 'NP', 'NEPAL', 'Nepal', 'NPL', 524, 977),
(150, 'NL', 'NETHERLANDS', 'Netherlands', 'NLD', 528, 31),
(151, 'AN', 'NETHERLANDS ANTILLES', 'Netherlands Antilles', 'ANT', 530, 599),
(152, 'NC', 'NEW CALEDONIA', 'New Caledonia', 'NCL', 540, 687),
(153, 'NZ', 'NEW ZEALAND', 'New Zealand', 'NZL', 554, 64),
(154, 'NI', 'NICARAGUA', 'Nicaragua', 'NIC', 558, 505),
(155, 'NE', 'NIGER', 'Niger', 'NER', 562, 227),
(156, 'NG', 'NIGERIA', 'Nigeria', 'NGA', 566, 234),
(157, 'NU', 'NIUE', 'Niue', 'NIU', 570, 683),
(158, 'NF', 'NORFOLK ISLAND', 'Norfolk Island', 'NFK', 574, 672),
(159, 'MP', 'NORTHERN MARIANA ISLANDS', 'Northern Mariana Islands', 'MNP', 580, 1670),
(160, 'NO', 'NORWAY', 'Norway', 'NOR', 578, 47),
(161, 'OM', 'OMAN', 'Oman', 'OMN', 512, 968),
(162, 'PK', 'PAKISTAN', 'Pakistan', 'PAK', 586, 92),
(163, 'PW', 'PALAU', 'Palau', 'PLW', 585, 680),
(164, 'PS', 'PALESTINIAN TERRITORY, OCCUPIED', 'Palestinian Territory, Occupied', NULL, NULL, 970),
(165, 'PA', 'PANAMA', 'Panama', 'PAN', 591, 507),
(166, 'PG', 'PAPUA NEW GUINEA', 'Papua New Guinea', 'PNG', 598, 675),
(167, 'PY', 'PARAGUAY', 'Paraguay', 'PRY', 600, 595),
(168, 'PE', 'PERU', 'Peru', 'PER', 604, 51),
(169, 'PH', 'PHILIPPINES', 'Philippines', 'PHL', 608, 63),
(170, 'PN', 'PITCAIRN', 'Pitcairn', 'PCN', 612, 0),
(171, 'PL', 'POLAND', 'Poland', 'POL', 616, 48),
(172, 'PT', 'PORTUGAL', 'Portugal', 'PRT', 620, 351),
(173, 'PR', 'PUERTO RICO', 'Puerto Rico', 'PRI', 630, 1787),
(174, 'QA', 'QATAR', 'Qatar', 'QAT', 634, 974),
(175, 'RE', 'REUNION', 'Reunion', 'REU', 638, 262),
(176, 'RO', 'ROMANIA', 'Romania', 'ROM', 642, 40),
(177, 'RU', 'RUSSIAN FEDERATION', 'Russian Federation', 'RUS', 643, 70),
(178, 'RW', 'RWANDA', 'Rwanda', 'RWA', 646, 250),
(179, 'SH', 'SAINT HELENA', 'Saint Helena', 'SHN', 654, 290),
(180, 'KN', 'SAINT KITTS AND NEVIS', 'Saint Kitts and Nevis', 'KNA', 659, 1869),
(181, 'LC', 'SAINT LUCIA', 'Saint Lucia', 'LCA', 662, 1758),
(182, 'PM', 'SAINT PIERRE AND MIQUELON', 'Saint Pierre and Miquelon', 'SPM', 666, 508),
(183, 'VC', 'SAINT VINCENT AND THE GRENADINES', 'Saint Vincent and the Grenadines', 'VCT', 670, 1784),
(184, 'WS', 'SAMOA', 'Samoa', 'WSM', 882, 684),
(185, 'SM', 'SAN MARINO', 'San Marino', 'SMR', 674, 378),
(186, 'ST', 'SAO TOME AND PRINCIPE', 'Sao Tome and Principe', 'STP', 678, 239),
(187, 'SA', 'SAUDI ARABIA', 'Saudi Arabia', 'SAU', 682, 966),
(188, 'SN', 'SENEGAL', 'Senegal', 'SEN', 686, 221),
(189, 'CS', 'SERBIA AND MONTENEGRO', 'Serbia and Montenegro', NULL, NULL, 381),
(190, 'SC', 'SEYCHELLES', 'Seychelles', 'SYC', 690, 248),
(191, 'SL', 'SIERRA LEONE', 'Sierra Leone', 'SLE', 694, 232),
(192, 'SG', 'SINGAPORE', 'Singapore', 'SGP', 702, 65),
(193, 'SK', 'SLOVAKIA', 'Slovakia', 'SVK', 703, 421),
(194, 'SI', 'SLOVENIA', 'Slovenia', 'SVN', 705, 386),
(195, 'SB', 'SOLOMON ISLANDS', 'Solomon Islands', 'SLB', 90, 677),
(196, 'SO', 'SOMALIA', 'Somalia', 'SOM', 706, 252),
(197, 'ZA', 'SOUTH AFRICA', 'South Africa', 'ZAF', 710, 27),
(198, 'GS', 'SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS', 'South Georgia and the South Sandwich Islands', NULL, NULL, 0),
(199, 'ES', 'SPAIN', 'Spain', 'ESP', 724, 34),
(200, 'LK', 'SRI LANKA', 'Sri Lanka', 'LKA', 144, 94),
(201, 'SD', 'SUDAN', 'Sudan', 'SDN', 736, 249),
(202, 'SR', 'SURINAME', 'Suriname', 'SUR', 740, 597),
(203, 'SJ', 'SVALBARD AND JAN MAYEN', 'Svalbard and Jan Mayen', 'SJM', 744, 47),
(204, 'SZ', 'SWAZILAND', 'Swaziland', 'SWZ', 748, 268),
(205, 'SE', 'SWEDEN', 'Sweden', 'SWE', 752, 46),
(206, 'CH', 'SWITZERLAND', 'Switzerland', 'CHE', 756, 41),
(207, 'SY', 'SYRIAN ARAB REPUBLIC', 'Syrian Arab Republic', 'SYR', 760, 963),
(208, 'TW', 'TAIWAN, PROVINCE OF CHINA', 'Taiwan, Province of China', 'TWN', 158, 886),
(209, 'TJ', 'TAJIKISTAN', 'Tajikistan', 'TJK', 762, 992),
(210, 'TZ', 'TANZANIA, UNITED REPUBLIC OF', 'Tanzania, United Republic of', 'TZA', 834, 255),
(211, 'TH', 'THAILAND', 'Thailand', 'THA', 764, 66),
(212, 'TL', 'TIMOR-LESTE', 'Timor-Leste', NULL, NULL, 670),
(213, 'TG', 'TOGO', 'Togo', 'TGO', 768, 228),
(214, 'TK', 'TOKELAU', 'Tokelau', 'TKL', 772, 690),
(215, 'TO', 'TONGA', 'Tonga', 'TON', 776, 676),
(216, 'TT', 'TRINIDAD AND TOBAGO', 'Trinidad and Tobago', 'TTO', 780, 1868),
(217, 'TN', 'TUNISIA', 'Tunisia', 'TUN', 788, 216),
(218, 'TR', 'TURKEY', 'Turkey', 'TUR', 792, 90),
(219, 'TM', 'TURKMENISTAN', 'Turkmenistan', 'TKM', 795, 7370),
(220, 'TC', 'TURKS AND CAICOS ISLANDS', 'Turks and Caicos Islands', 'TCA', 796, 1649),
(221, 'TV', 'TUVALU', 'Tuvalu', 'TUV', 798, 688),
(222, 'UG', 'UGANDA', 'Uganda', 'UGA', 800, 256),
(223, 'UA', 'UKRAINE', 'Ukraine', 'UKR', 804, 380),
(224, 'AE', 'UNITED ARAB EMIRATES', 'United Arab Emirates', 'ARE', 784, 971),
(225, 'GB', 'UNITED KINGDOM', 'United Kingdom', 'GBR', 826, 44),
(226, 'US', 'UNITED STATES', 'United States', 'USA', 840, 1),
(227, 'UM', 'UNITED STATES MINOR OUTLYING ISLANDS', 'United States Minor Outlying Islands', NULL, NULL, 1),
(228, 'UY', 'URUGUAY', 'Uruguay', 'URY', 858, 598),
(229, 'UZ', 'UZBEKISTAN', 'Uzbekistan', 'UZB', 860, 998),
(230, 'VU', 'VANUATU', 'Vanuatu', 'VUT', 548, 678),
(231, 'VE', 'VENEZUELA', 'Venezuela', 'VEN', 862, 58),
(232, 'VN', 'VIET NAM', 'Viet Nam', 'VNM', 704, 84),
(233, 'VG', 'VIRGIN ISLANDS, BRITISH', 'Virgin Islands, British', 'VGB', 92, 1284),
(234, 'VI', 'VIRGIN ISLANDS, U.S.', 'Virgin Islands, U.s.', 'VIR', 850, 1340),
(235, 'WF', 'WALLIS AND FUTUNA', 'Wallis and Futuna', 'WLF', 876, 681),
(236, 'EH', 'WESTERN SAHARA', 'Western Sahara', 'ESH', 732, 212),
(237, 'YE', 'YEMEN', 'Yemen', 'YEM', 887, 967),
(238, 'ZM', 'ZAMBIA', 'Zambia', 'ZMB', 894, 260),
(239, 'ZW', 'ZIMBABWE', 'Zimbabwe', 'ZWE', 716, 263);


INSERT INTO aidb.jump_servers (fqdn, ip) VALUES ('localhost', 	host('127.0.0.1/24'));
