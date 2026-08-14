import Exam697 from "./Exam_697-01.png";
import Exam698 from "./Exam_698-01.png";
import Exam703 from "./Exam-703.png";
import MCSAWindows10 from "./MCSA_Windows10.png";
import MCSEMobility from "./MCSE-Mobility-2018.png";
import MicrosoftGeneral from "./microsoft-certified-general-badge.png";
import MicrosoftAssociate from "./microsoft-certified-associate-badge.png";
import MicrosoftExpert from "./microsoft-certified-expert-badge.png";
import CompTIAA from "./CompTIA_A.png";
import CompTIANetwork from "./COMPTIA_Network.png";
import CompTIAProject from "./COMPTIA_Project.png";
import CISBenchmarks from "./CIS_2026.png";
import ITILv4 from "./ITIL-4-Foundation.png";

// Edit the `description` field on any entry below to add your own
// blurb about what the certification covers / why you earned it.
export const groups = [
  {
    name: "Microsoft",
    certs: [
      {
        image: MicrosoftAssociate,
        title: "Microsoft 365 Certified: Endpoint Administrator Associate",
        issuer: "Microsoft",
        date: "September 2023",
      },
      {
        image: MicrosoftExpert,
        title: "Microsoft 365 Certified: Administrator Expert",
        issuer: "Microsoft",
        date: "August 2026",
      },
      {
        image: MCSEMobility,
        title: "MCSE: Mobility",
        issuer: "Microsoft",
        date: "November 2018",
      },
      {
        image: MCSAWindows10,
        title: "MCSA: Windows 10",
        issuer: "Microsoft",
        date: "October 2018",
      },
    ],
  },
  {
    name: "ITIL",
    certs: [
      {
        image: ITILv4,
        title: "ITILv4 Foundation",
        issuer: "PeopleCert",
        date: "December 2024",
      },
    ],
  },
  {
    name: "CompTIA",
    certs: [
      {
        image: CompTIAProject,
        title: "CompTIA Project+",
        issuer: "CompTIA",
        date: "",
      },
      {
        image: CompTIANetwork,
        title: "CompTIA Network+",
        issuer: "CompTIA",
        date: "",
      },
      {
        image: CompTIAA,
        title: "CompTIA A+",
        issuer: "CompTIA",
        date: "",
      },
    ],
  },
  {
    name: "Other",
    certs: [
      {
        image: CISBenchmarks,
        title: "CIS Benchmarks Community Contributor",
        issuer: "Center for Internet Security",
        date: "2026",
      },
    ],
  },
];
