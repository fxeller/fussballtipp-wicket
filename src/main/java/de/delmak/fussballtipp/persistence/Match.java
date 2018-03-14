package de.delmak.fussballtipp.persistence;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class Match extends HibernateObject
{

	private Integer matchId;

	public Integer getMatchId()
	{
		return matchId;
	}

	public void setMatchId(Integer matchId)
	{
		this.matchId = matchId;
	}

	private Phase phase;

	public Phase getPhase()
	{
		return phase;
	}

	public void setPhase(Phase phase)
	{
		this.phase = phase;
	}

	private Date datetime;

	public Date getDatetime()
	{
		return datetime;
	}

	public void setDatetime(Date datetime)
	{
		this.datetime = datetime;
	}
	
	private Team teamHome;

	public Team getTeamHome()
	{
		return teamHome;
	}

	public void setTeamHome(Team teamHome)
	{
		this.teamHome = teamHome;
	}

	private Team TeamGuest;

	public Team getTeamGuest()
	{
		return TeamGuest;
	}

	public void setTeamGuest(Team TeamGuest)
	{
		this.TeamGuest = TeamGuest;
	}

	private Integer scoreHome;

	public Integer getScoreHome()
	{
		return scoreHome;
	}

	public void setScoreHome(Integer scoreHome)
	{
		this.scoreHome = scoreHome;
	}

	private Integer scoreGuest;

	public Integer getScoreGuest()
	{
		return scoreGuest;
	}

	public void setScoreGuest(Integer scoreGuest)
	{
		this.scoreGuest = scoreGuest;
	}

	private Boolean isfinals;

	public Boolean isIsfinals()
	{
		return isfinals;
	}

	public void setIsfinals(Boolean isfinals)
	{
		this.isfinals = isfinals;
	}

	public Boolean getIsOpenForBets()
	{
		Calendar currentDateTime = Calendar.getInstance();
		Calendar closingDateTime = Calendar.getInstance();
		closingDateTime.setTime(getDatetime());
		closingDateTime.add(Calendar.MINUTE, -30);
		
		return (currentDateTime.before(closingDateTime) == true);
	}

	@Override
	public String toString()
	{
		return String.format("%s_%s_%s_%s", getClass().getName(), getDatetime().toString(), getTeamHome().getTeamname(), getTeamGuest().getTeamname());
	}
	
	@Override
	public boolean equals(Object obj)
	{
		return obj.toString().equals(toString());				
	}

	@Override
	public int hashCode()
	{
		return toString().hashCode();
	}
	
	public static void insert(Match object)
	{
		try
		{
			beginTransaction();
			getSession().save(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static void modify(Match object)
	{
		try
		{
			beginTransaction();
			getSession().update(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static void delete(Match object)
	{
		try
		{
			beginTransaction();
			getSession().delete(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static Match getById(int id)
	{
		try
		{
			beginTransaction();
			
			Match result = (Match) getSession()
					.getNamedQuery("getMatchById")
					.setInteger("id", id)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}

	public static Match getByIsfinals(Boolean isfinals)
	{
		try
		{
			beginTransaction();
			
			Match result = (Match) getSession()
					.getNamedQuery("getMatchByIsfinals")
					.setBoolean("isfinals", isfinals)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}

	public static List getListAll()
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getMatchesAll")
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static List getListByPhaseId(Integer phaseId)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getMatchesByPhaseId")
					.setInteger("phaseId", phaseId)
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
}
