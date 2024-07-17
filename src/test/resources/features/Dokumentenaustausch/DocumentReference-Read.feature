@dokumentenaustausch
@mandatory
@DocumentReference-Read
Feature: Lesen der Ressource DocumentReference (@DocumentReference-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'documentreference-read-id' hinterlegt sein.

      Legen Sie die folgenden Dokumentenmetadaten in Ihrem System an:
      Versionsspezifische OID des Dokumentes: urn:oid:1.2.840.113556.1.8000.2554.58783.21864.3474.19410.44358.58254.41281.46340
      Externer Identifier (Wert, System): 129.6.58.42.33726, urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8
      Status: Aktuell
      Dokumentenstatus: Abgeschlossen
      Dokumentklasse: Befundbericht
      Dokumenttyp (KDL): Molekularpathologiebefund
      Dokumenttyp (XDS): Pathologiebefundberichte
      Patientenbezug: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'documentreference-read-patient-id' hinterlegt sein)
      Author: Maxine Mustermann
      Beziehung zu anderen Dokumenten: Dieses Dokument ersetzt ein (beliebiges) Dokument
      Beschreibung: Molekularpathologiebefund vom 31.12.21
      Vertraulichkeit: Normal
      Inhalt: Deutschsprachige PDF, erstellt 2020-12-31T23:50:50
      Kontext: Pathologiebesuch im Krankenhaus
      Kontakt/Fall: Beliebig (die verknüpfte Encounter-Ressource muss konform zu ISIKKontaktGesundheitseinrichtung sein, , die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'documentreference-read-encounter-id' hinterlegt sein)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "DocumentReference"

  Scenario: Read von Dokumentenmetadaten anhand der ID
    Then Get FHIR resource at "http://fhirserver/DocumentReference/${data.documentreference-read-id}" with content type "xml"
    And resource has ID "${data.documentreference-read-id}"
    And FHIR current response body is a valid isik3-dokumentenaustausch resource and conforms to profile "https://gematik.de/fhir/isik/v3/Dokumentenaustausch/StructureDefinition/ISiKDokumentenMetadaten"
    And FHIR current response body evaluates the FHIRPath "masterIdentifier.where(system = 'urn:ietf:rfc:3986' and value = 'urn:oid:1.2.840.113556.1.8000.2554.58783.21864.3474.19410.44358.58254.41281.46340').exists()" with error message 'Die versionsspezifische OID des Dokumentes entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "identifier.where(system = 'urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8' and value = '129.6.58.42.33726').exists()" with error message 'Der Identifier entspricht nicht dem Erwartungswert'
    And TGR current response with attribute "$..status.value" matches "current"
    And TGR current response with attribute "$..docStatus.value" matches "final"
    And TGR current response with attribute "$..description.value" matches "Molekularpathologiebefund vom 31.12.21"
    And FHIR current response body evaluates the FHIRPath "type.coding.where(system = 'http://dvmd.de/fhir/CodeSystem/kdl' and code = 'PT130102' and display = 'Molekularpathologiebefund').exists()" with error message 'Der Dokumententyp (KDL) Code entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "type.coding.where(system = 'http://ihe-d.de/CodeSystems/IHEXDStypeCode' and code = 'PATH' and display = 'Pathologiebefundberichte').exists()" with error message 'Der Dokumententyp (XDS) Code entspricht nicht dem Erwartungswert'
    And element "subject" references resource with ID "${data.documentreference-read-patient-id}" with error message "Der Patientenbezug entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "context.encounter.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.documentreference-read-encounter-id}$')" with error message 'Referenzierter Fall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "author.display.contains('Maxine Mustermann')" with error message 'Die Autorin des Dokumentes entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "relatesTo.where(code = 'replaces' and target.reference.exists()).exists()" with error message 'Die Information über die Beziehung zum zu ersetzenden Dokument entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "securityLabel.coding.where(code = 'N' and system = 'http://terminology.hl7.org/CodeSystem/v3-Confidentiality').exists()" with error message 'Die Vertraulichkeit entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "content.where(attachment.where(contentType = 'application/pdf' and language = 'de' and url.exists() and creation.toString().contains('2020-12-31T23:50:50')).exists() and format.where(code = 'urn:ihe:iti:xds:2017:mimeTypeSufficient' and system = 'http://ihe.net/fhir/ihe.formatcode.fhir/CodeSystem/formatcode').exists()).exists()" with error message 'Der Anhang entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "context.where(facilityType.coding.where(code = 'KHS' and system = 'http://ihe-d.de/CodeSystems/PatientBezogenenGesundheitsversorgung').exists() and practiceSetting.where(coding.where(code = 'PATH' and system = 'http://ihe-d.de/CodeSystems/AerztlicheFachrichtungen').exists()).exists()).exists()" with error message 'Der Kontext entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "category.coding.where(code = 'BEF' and system = 'http://ihe-d.de/CodeSystems/IHEXDSclassCode' and display = 'Befundbericht').exists()" with error message 'Die Dokumentklasse entspricht nicht dem Erwartungswert'
    
    And referenced Patient resource with id "${data.documentreference-read-patient-id}" conforms to ISiKPatient profile
    And referenced Encounter resource with id "${data.documentreference-read-encounter-id}" conforms to ISiKKontaktGesundheitseinrichtung profile
